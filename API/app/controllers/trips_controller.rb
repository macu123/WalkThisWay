class TripsController < ApplicationController

  def index

    redirect_to new_trip_path

  end

  def new

    origin = "639 Queen Street West Toronto"
    destination = "Queen and Spadina Toronto"

    api_url = 'https://maps.googleapis.com/maps/api/directions/json?' + 'origin=' + origin + '&destination=' +  destination + '&mode='
    key = '&key=' + 'AIzaSyCR5fUOPVxtqsSR5Oy3jIQ4P-f0tLMYj9k'

    walk_url = api_url.gsub!(' ', '+') + 'walking' + key
    walk_response = HTTParty.get(walk_url)
    walk_time = walk_response["routes"][0]["legs"][0]["steps"][0]["duration"]["value"]

    transit_url = api_url + 'transit' + key
    transit_response = HTTParty.get(transit_url)
    transit_time = transit_response["routes"][0]["legs"][0]["steps"][0]["duration"]["value"]

    # binding.pry

    response={ walk_time: walk_time, transit_time: transit_time}

    render json: response

  end

end


