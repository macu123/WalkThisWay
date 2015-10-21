require 'open-uri'
require_relative '../services/trip_planner'

class TripsPlannerController < ApplicationController

  def create

    startpoint = params[:startpoint]
    endpoint = params[:endpoint]

    response = TripPlanner.plan_trip(startpoint, endpoint)
    puts 2
    puts response
    puts 2
    render json: response

  end

end