class User < ActiveRecord::Base
  # Include default devise modules.
  devise :database_authenticatable, :registerable,
          :recoverable, :rememberable, :trackable, :validatable,
          :confirmable, :omniauthable
  include DeviseTokenAuth::Concerns::User
	has_secure_password
	has_many :trips

	#validations
	validates :first_name, :last_name, :email, :password_digest, presence: true
	validates :email, uniqueness: true

end
