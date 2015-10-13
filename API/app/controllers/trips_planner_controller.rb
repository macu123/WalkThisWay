require 'open-uri'
require_relative '../services/trip_planner'

class TripsPlannerController < ApplicationController

  def create

    startpoint = params[:startpoint]
    endpoint = params[:endpoint]

    response = TripPlanner.plan_trip(startpoint, endpoint)

    render json: response

  end

end