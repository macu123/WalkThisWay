class User < ActiveRecord::Base
	has_secure_password
	has_many :trips

	#validations
	validates :first_name, :last_name, :email, :password_digest, presence: true
	validates :email, uniqueness: true

end
