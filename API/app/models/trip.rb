class Trip < ActiveRecord::Base
	belongs_to :user

	validates :user, presence: true
	validates :start_latitude, :start_longitude, :end_latitude, :end_longitude, :trip_name, presence: true


end
