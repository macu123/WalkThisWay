class TripsController < ApplicationController

  def index

  end

  def new
  	@trip = Trip.new
  end

  def create
  	@user = User.find_by(email:params[:email])
  	@trip = Trip.new(start_latitude: params[:start_lat], start_longitude: params[:start_long], 
  		end_latitude: params[:end_lat], end_longitude: params[:end_long], trip_name: params[:trip_name], user_id:@user.id)

  	if @trip.save
  		render json: response = {saved: true}
  	else
  		render json: response = {saved: false}
  	end
  end

  def edit

  end

  def update

  end

  def show
   	@user = User.find_by(email:params[:email])
  	response = {}

  	@trips = Trip.where(user_id:@user.id) 
  	@trips = @trips.as_json

  	if @trips != nil 		
  		response[:email] = @user.email
  		response[:trips] = @trips
  	else
  		response[:has_trips] = false
   	end


	  render json: response
  end

  def destroy
  	Trip.find(params[:id]).destroy
  	response = {trip: "destroyed"}
  	render json: response
  end

  protected

  def trip_params
  	params.require(:trip).permit(:user_id, :start_latitude, :start_longitude, :end_latitude, :end_longitude, :trip_name)
  end
end




