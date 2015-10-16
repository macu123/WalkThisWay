require 'securerandom'

class SessionsController < ApplicationController

	def new
	end

	def create
		@user = User.find_by(email: params[:email])
		puts @user

		if @user && @user.authenticate(params[:password])			
		
			token = SecureRandom.hex
			response = {username: @user.first_name, email: @user.email, token: token}

			@user.token = token
			@user.save
		else 
			response = {"fuck" => "you"}
		end

		render json: response
	end

	def remove
		@user = User.find_by(email: params[:email])
		@user.token = nil
		@user.save
		response = {"fuck" => "you" }
		render json: response
	end
end
