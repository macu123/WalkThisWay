require 'open-uri'

class TripsController < ApplicationController

  def index

    redirect_to new_trip_path

  end

  def new

    origin = "639 Queen West Toronto"
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
        lat = nearest_stop["lat"].to_s[0..-3]
        route_tag = transit_response["routes"][0]["legs"][0]["steps"][1]["transit_details"]["line"]["short_name"]
        instructions = transit_response["routes"][0]["legs"][0]["steps"][0]["html_instructions"]
        intersection = instructions.split("Walk to ")[1]

        route_url = 'http://webservices.nextbus.com/service/publicXMLFeed?command=routeConfig&a=ttc&r=' + route_tag
        routes = Nokogiri::HTML(open(route_url))
        stops = routes.xpath("//route//stop").to_s.split("</stop>")
        target = nil
        stops.each do |stop|
          if stop.include? (lat)
            target = stop
          end
        end
        stop_id = target.split('stopid')[1].partition(/\d{4}/)[1]

        arrivals_url = 'http://webservices.nextbus.com/service/publicXMLFeed?command=predictions&a=ttc&stopId=' + stop_id
        arrivals = Nokogiri::HTML(open(arrivals_url))
        arrival = arrivals.xpath("//direction//prediction").to_s.split("</prediction>")[0].split("seconds=")[1].split("minutes")[0].partition(/\d{3}/)[1]

    response = { walk_time: walk_time, transit_time: transit_time, 
                nearest_stop: nearest_stop, route_tag: route_tag, instructions: instructions,
                intersection: intersection, arrival: arrival, total_transit: (transit_time + arrival)}

    # binding.pry

    render json: response

  end

end


