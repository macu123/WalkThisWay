require 'open-uri'
require_relative '../services/trip_planner'

class TripsPlannerController < ApplicationController

  def index

    startpoint = params[:startpoint]
    endpoint = params[:endpoint]

    TripPlanner.plan_trip(startpoint, endpoint)

  end

end