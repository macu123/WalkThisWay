class TripsController < ApplicationController

  def create

    url = 'https://maps.googleapis.com/maps/api/directions/json?'
    origin = ""
    destination = ""

    key = "AIzaSyCR5fUOPVxtqsSR5Oy3jIQ4P-f0tLMYj9k"

    mode = "walking"

    response = HTTParty.get('#{url}origin=#{origin}&destination=#{destination}&key=#{key}')
  end

end


