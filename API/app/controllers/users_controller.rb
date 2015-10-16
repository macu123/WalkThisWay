class UsersController < ApplicationController
	
	def index
		if params[:token]
			token = params[:token]
			@user = User.find_by(token: token)
			if @user
				response = {username: @user.first_name + " " + @user.last_name, email: @user.email}
				render json: response
			else
				response = {username:nil, email:nil}
				render json: response
			end
		# else
		# 	@user = User.all
		# 	response = {name:nil, email:nil}
		# 	render json: response
		end
  end

  def new
  	@user = User.new
  end

  def create
  	@user = User.new(first_name:params[:first_name], last_name:params[:last_name], email:params[:email], password:params[:password], password_confirmation:params[:password_confirmation])
  	puts params
  	if @user.save
  		token = SecureRandom.hex
			response = {username: @user.first_name + " " + @user.last_name, email: @user.email, token: token}
			@user.token = token
			@user.save  	
			render json: response
		elsif User.find_by(email:params[:email])
			response={error: "EMAIL ALREADY EXISTS"}
			render json: response
		else
			response={error:"SOMETHING WENT WRONG"}
			render json: response
		end

  end

  def edit

  end

  def update

  end

  def show

  end

  def destroy

  end

  protected

  def user_params
  	params.require(:user).permit(:email, :first_name, :last_name, :password, :password_confirmation, :token)
  end
end
