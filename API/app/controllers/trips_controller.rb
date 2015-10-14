class TripsController < ApplicationController

  def index

  end

  def new
  	@trip = Trip.new
  end

  def create
  	@trip = Trip.new(trip_params)
  end

  def edit

  end

  def update

  end

  def show
  	@user = User.find(session[:user_id])
  	if @user
	  	if params[:token] == @user.token
	  		@trips = Trip.find_by(session[:user_id])
	  		response = @trips
	  	else
	  		response = {"fuck": "you"}
	  	end
	  else
	  	response = {"fuck": "you"}
	  end
	  render json: response
  end

  def destroy

  end

  protected

  def trip_params
  	params.require(:trip).permit(:user_id, :start_latitude, :start_longitude, :end_latitude, :end_longitude, :startpoint, :endpoint)
  end
end




