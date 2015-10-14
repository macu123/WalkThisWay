require 'securerandom'

class SessionsController < ApplicationController

	def new
	end

	def create
		@user = User.find_by(email: params[:email])
		puts @user

		if @user && @user.authenticate(params[:password])
			puts "correct"

			session[:user_id] = @user.id

			token = SecureRandom.hex
			response = {username: @user.first_name, email: @user.email, token: token}

			@user.token = token
			@user.save
		else 
			response = {"fuck": "you"}
		end

		render json: response
	end

	def destroy
		@user = User.find(session[:user_id])
		@user.token = nil
		session[:user_id] = nil
	end
end
