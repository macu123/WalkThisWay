class TripsController < ApplicationController

  def index

  end

  def new
  	@trip = Trip.new
  end

  def create
  	@user = User.find_by(email:params[:email])
  	# binding.pry
  	@trip = Trip.new(start_latitude: params[:start_lat], start_longitude: params[:start_long], 
  		end_latitude: params[:end_lat], end_longitude: params[:end_long], trip_name: params[:trip_name], user_id:@user.id)
  	if @trip.save
  		render json: response = {"it"=>"worked"}
  	else
  		render json: response = {"it"=>"fucked up"}
  	end
  end

  def edit

  end

  def update

  end

  def show
  	@user = User.find_by(email:params[:email])
  	response = {}
  	if @user
	  	if params[:token] == @user.token
	  		# @trips = Trip.find_by(session[:user_id])
	  		# response << @trips
	  		response.email = @user.email
	  	else
	  		response = {"fuck"=>"you"}
	  	end
	  else
	  	response = {"fuck"=>"you"}
	  end
	  render json: response
  end

  def destroy

  end

  protected

  def trip_params
  	params.require(:trip).permit(:user_id, :start_latitude, :start_longitude, :end_latitude, :end_longitude, :trip_name)
  end
end




