class TripsController < ApplicationController

  def index

    redirect_to new_trip_path

  end

  def new

    api_url = 'https://maps.googleapis.com/maps/api/directions/json?'
    origin = "639 Queen Street West Toronto"
    destination = "Queen and Spadina Toronto"
    key = "AIzaSyCR5fUOPVxtqsSR5Oy3jIQ4P-f0tLMYj9k"
    mode = "walking"

    url = api_url + 'origin=' + origin + '&destination=' +  destination + '&mode=' + mode + '&key=' + key

    url.gsub!(" ", "+")

    response = HTTParty.get(url)
  
    render json: response

  end

end


