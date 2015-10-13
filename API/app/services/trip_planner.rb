class TripPlanner

  def self.plan_trip(startpoint, endpoint)

    origin = startpoint
    destination = endpoint

    api_url = 'https://maps.googleapis.com/maps/api/directions/json?' + 'origin=' + origin + '&destination=' +  destination + '&mode='
    key = '&key=' + 'AIzaSyCR5fUOPVxtqsSR5Oy3jIQ4P-f0tLMYj9k'
        # binding.pry
        walk_url = api_url.gsub!(' ', '+') + 'walking' + key
        walk_response = HTTParty.get(walk_url)
        walk_time = walk_response["routes"][0]["legs"][0]["duration"]["value"]

        transit_url = api_url + 'transit' + '&transit_routing_preference=less_walking' + key
        transit_response = HTTParty.get(transit_url)
        total_transit_time = nil

            transit_time = transit_response["routes"][0]["legs"][0]["duration"]["value"]
            walk_to_stop_time = transit_response["routes"][0]["legs"][0]["steps"][0]["duration"]["value"]
            nearest_stop = transit_response["routes"][0]["legs"][0]["steps"][0]["end_location"]
            lat = nearest_stop["lat"].to_s[0..6]
            step_one = transit_response["routes"][0]["legs"][0]["steps"][0]["travel_mode"]
            instructions = transit_response["routes"][0]["legs"][0]["steps"][0]["html_instructions"]
            route_tag = transit_response["routes"][0]["legs"][0]["steps"][0]["transit_details"]["line"]["short_name"]
            direction = transit_response["routes"][0]["legs"][0]["steps"][0]["transit_details"]["headsign"].split(" - ")[0]

            if step_one == "WALKING"
                intersection = instructions.split("Walk to ")[1].gsub!(" at "," At ")
            else
                intersection = transit_response["routes"][0]["legs"][0]["steps"][0]["transit_details"]["departure_stop"]["name"].gsub!(" at "," At ")
            end

            route_url = 'http://webservices.nextbus.com/service/publicXMLFeed?command=routeConfig&a=ttc&r=' + route_tag
            routes = Nokogiri::HTML(open(route_url))
            stops = routes.xpath("//route//stop").to_s.split("</stop>")
            targets = []
            stop = nil
            stops.each do |s|
              if s.include? intersection
                targets << s
              end
            end

            if direction == "East" || direction == "North"
                stop = targets[0]
            elsif direction == "West" || direction == "South"
                stop = targets[1]
            end

            # binding.pry
            stop_id = stop.split('stopid')[1].partition(/\d{4}/)[1]

            arrivals_url = 'http://webservices.nextbus.com/service/publicXMLFeed?command=predictions&a=ttc&stopId=' + stop_id
            arrivals = Nokogiri::HTML(open(arrivals_url))
            arrival = arrivals.xpath("//direction//prediction").to_s.split("</prediction>")[0].split("seconds=")[1].split("minutes")[0].partition(/\d{3}/)[1].to_i
            total_transit_time = transit_time.to_i + arrival

            # if ( ( arrival - walk_to_stop_time ) >= 30 ) && 
            # walk_to_destination_time > total_transit_time
            #   # wait for the bus
            # else
            #   # walk
            # end



        response = { 
                route_tag: route_tag,
                direction: direction,
                intersection: intersection, 
                vehicle_arrival: arrival,
                walk_to_stop_time: walk_to_stop_time,
                walk_to_destination_time: walk_time, 
                transit_time: transit_time,  
                total_transit_time: total_transit_time
                }

    # binding.pry

    response


  end


end