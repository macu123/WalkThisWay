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

  end

  def destroy

  end

  protected

  def trip_params
  	params.require(:trip).permit(:user_id, :start_latitude, :start_longitude, :end_latitude, :end_longitude, :startpoint, :endpoint)
  end
end




