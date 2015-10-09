class TripsController < ApplicationController

	def create
		startpoint = params[:startpoint]
  	endpoint = params[:endpoint]
  	
  	startpoint = startpoint + " IT FUCKING WORKED!!!!"
  	endpoint = endpoint + " YAYYYYYYYY"

  	response = {startpoint:startpoint, endpoint:endpoint}.to_json

  	render json: response
	end

end