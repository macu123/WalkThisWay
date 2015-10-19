require 'securerandom'

class SessionsController < ApplicationController

	def new
	end

	def create
		puts params[:email]
		@user = User.find_by(email: params[:email])
		puts @user.first_name
		puts @user.authenticate(params[:password])
		puts "-----------------------------"

		if @user.authenticate(params[:password])			
		
			token = SecureRandom.hex

			@user.token = token
			@user.save

			response = {username: @user.first_name, email: @user.email, token: token, login: true}
		else 
			response = {login: false}
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
