class User < ApplicationRecord
	# Include default devise modules. Others available are:
	# :confirmable, :lockable, :timeoutable and :omniauthable
	devise :database_authenticatable, :registerable,
	     :recoverable, :rememberable, :trackable, :validatable,
	     :omniauthable, omniauth_providers: %i[facebook twitter saml_idp1]

	def self.from_omniauth(auth)
		where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
			user.provider = auth.provider
			user.uid = auth.uid
			# user.email = 'temp_email@test.com' Used a dummy email bc of twitter
			user.email = auth.info.email
			user.password = Devise.friendly_token[0,20]
			user.name = auth.info.name   # assuming the user model has a name
			# user.image = auth.info.image # assuming the user model has an image
			# If you are using confirmable and the provider(s) you use validate emails,
			# uncomment the line below to skip the confirmation emails.
			# user.skip_confirmation!
		end
	end

	# def self.new_with_session(params, session)
	# 	super.tap do |user|
	# 		if data = session["devise.facebook_data"] && session["devise.facebook_data"]["extra"]["raw_info"]
	# 			user.email = data["email"] if user.email.blank?
	# 		end
	# 	end
	# end

	def self.new_with_session(params, session)
		if session["devise.user_attributes"]
			new(session["devise.user_attributes"]) do |user|
				user.attributes = params
				user.valid?
			end
		else
			super
		end
	end
end
