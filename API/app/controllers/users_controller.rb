class UsersController < ApplicationController
	def index

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
  	params.require(:user).permit(:email, :first_name, :last_name, :password, :password_confirmation)
  end
end
