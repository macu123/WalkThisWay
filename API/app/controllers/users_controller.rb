class UsersController < ApplicationController
	
	def index
		if params
			token = params[:token]
			@user = User.find_by(token: token)
			if @user
				response = {name: @user.first_name + " " + @user.last_name, email: @user.email}
				render json: response
			else
				response = {name:nil, email:nil}
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
  	@user = User.new(user_params)

  	if @user.save
  		session[:user_id] = @user.user_id
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
