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
    walk_time = walk_response["routes"][0]["legs"][0]["duration"]["value"]

    transit_url = api_url + 'transit' + key
    transit_response = HTTParty.get(transit_url)
    transit_time = transit_response["routes"][0]["legs"][0]["duration"]["value"]
    nearest_stop = transit_response["routes"][0]["legs"][0]["steps"][0]["end_location"]
    route_tag = transit_response["routes"][0]["legs"][0]["steps"][1]["transit_details"]["line"]["short_name"]

    response = { walk_time: walk_time, transit_time: transit_time, 
                nearest_stop: nearest_stop, tag: route_tag}

    # binding.pry

    render json: response

  end

end


