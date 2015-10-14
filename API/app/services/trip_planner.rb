class TripPlanner

  def self.api(s,e)
    origin = s.gsub(' ', '+') + '+Toronto'
    destination = e.gsub(' ', '+') + '+Toronto'
    url = 'https://maps.googleapis.com/maps/api/directions/json?' + 'origin=' + origin + '&destination=' +  destination + '&mode='
  end

  def self.walk_time
    walk_response = HTTParty.get(@api_url + 'walking' + @key)
    walk_time = walk_response["routes"][0]["legs"][0]["duration"]["value"]
  end

  def self.get_arrival(path)
    arrivals = path.xpath("//direction//prediction").to_s.split("</prediction>")

    arrivals.map! do |a|
      a = a.split("seconds=")[1].split("minutes")[0].partition(/\d{3}/)[1].to_i
    end

    arrival = arrivals[0]

    arrivals.each do |t|
      if t
        if t - @walk_to_stop_time > 59
          if t < arrival
            arrival = t
          end
        end
      end
    end

    arrival
    
  end

  def self.plan_trip(startpoint,endpoint)

    @api_url = api(startpoint,endpoint)
    @key = '&key=' + 'AIzaSyCR5fUOPVxtqsSR5Oy3jIQ4P-f0tLMYj9k'
    total_transit_time = nil
        

    transit_url = @api_url + 'transit' + '&transit_routing_preference=less_walking' + @key
    transit_response = HTTParty.get(transit_url)

    transit_time = transit_response["routes"][0]["legs"][0]["duration"]["value"]
    nearest_stop = transit_response["routes"][0]["legs"][0]["steps"][0]["end_location"]
    step_one = transit_response["routes"][0]["legs"][0]["steps"][0]["travel_mode"]
    

    if step_one == "WALKING"
      instructions = transit_response["routes"][0]["legs"][0]["steps"][0]["html_instructions"]
      if instructions.include? (" at ")
        intersection = instructions.split("Walk to ")[1].gsub!(" at "," At ")
      else
        intersection = instructions.split("Walk to ")[1]
      end
      route_tag = transit_response["routes"][0]["legs"][0]["steps"][1]["transit_details"]["line"]["short_name"]
      direction = transit_response["routes"][0]["legs"][0]["steps"][1]["transit_details"]["headsign"].split(" - ")[0]
      @walk_to_stop_time = transit_response["routes"][0]["legs"][0]["steps"][0]["duration"]["value"]
    else
      onboard = transit_response["routes"][0]["legs"][0]["steps"][0]["transit_details"]["departure_stop"]["name"]
      if onboard.include? "Station"
        intersection = onboard
      else
        intersection = transit_response["routes"][0]["legs"][0]["steps"][0]["transit_details"]["departure_stop"]["name"].gsub!(" at "," At ")
      end
      route_tag = transit_response["routes"][0]["legs"][0]["steps"][0]["transit_details"]["line"]["short_name"]
      direction = transit_response["routes"][0]["legs"][0]["steps"][0]["transit_details"]["headsign"].split(" - ")[0]
      @walk_to_stop_time = 0
    end


    if route_tag.to_i > 4
      
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

      if direction == "East" || direction == "South"
          stop = targets.shift
      elsif direction == "West" || direction == "North"
          stop = targets.pop
      end

      stop_id = stop.split('stopid')[1].partition(/\d{4,5}/)[1]

      arrivals_url = 'http://webservices.nextbus.com/service/publicXMLFeed?command=predictions&a=ttc&stopId=' + stop_id
      @arrivals_doc = Nokogiri::HTML(open(arrivals_url))

      nextbus_direction = @arrivals_doc.xpath("//direction").to_s.split("<direction title=\"")[1].split(" - ")[0]
      
      if nextbus_direction != direction
          stop = targets[0]
          stop_id = stop.split('stopid')[1].partition(/\d{4,5}/)[1]
          arrivals_url = 'http://webservices.nextbus.com/service/publicXMLFeed?command=predictions&a=ttc&stopId=' + stop_id
          @arrivals_doc = Nokogiri::HTML(open(arrivals_url))
          upcoming_arrivals = @arrivals_doc.xpath("//direction//prediction").to_s.split("</prediction>")
      end

      arrival = get_arrival(@arrivals_doc)

      total_transit_time = transit_time.to_i + arrival

      if ( walk_time > total_transit_time )
        take_transit = true
      else
        take_transit = false
      end

    else
      if transit_time < walk_time
        take_transit = true
      else
        take_transit = false
      end
    end

    response = { 
      route_tag: route_tag,
      direction: direction,
      nextbus_direction: nextbus_direction,
      intersection: intersection, 
      vehicle_arrival: arrival,
      walk_to_stop_time: @walk_to_stop_time,
      walk_to_destination_time: walk_time, 
      transit_time: transit_time,  
      total_transit_time: total_transit_time,
      take_transit: take_transit
      }
  end

end