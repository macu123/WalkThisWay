class TripPlanner

  def self.format_input(s)
    if /[a-zA-Z]/.match(s)
      origin = s.gsub(/\D\d\D \d\D\d/,"").gsub(',','').gsub(' ', '+').gsub('Toronto','') + '+Toronto'
      origin = origin.gsub('++','+')
    else
      origin = s.gsub(',',' ').gsub(' ', '+')
    end
  end

  def self.api(s,e)
    @origin = format_input(s)
    @destination = format_input(e)
    url = 'https://maps.googleapis.com/maps/api/directions/json?' + 'origin=' + @origin + '&destination=' +  @destination + '&mode='
  end

  def self.get_walk_response
    encoded = URI.encode(@api_url + 'walking' + @key)
    walk_response = HTTParty.get(encoded)
  end

  def self.get_arrival(path)
    arrivals = path.xpath("//direction//prediction").to_s.split("</prediction>")
    arrivals.map! do |a|
      a = a.split("seconds=")[1].split("minutes")[0].partition(/\d{3}/)[1].to_i
    end

    arrival = nil

    arrivals.each do |t|
      if arrival
        if t - @walk_to_stop_time > 59
          if t < arrival
            arrival = t
          end
        end
      else
        if t - @walk_to_stop_time > 59
          arrival = t
        end
      end
    end
    arrival
  end

  def self.error
    if !@startpoint
      "Please enter a valid startpoint."
    elsif !@endpoint
      "Please enter a valid endpoint."
    elsif  @status == "NOT_FOUND" || @status == "ZERO_RESULTS" || @status == "INVALID_REQUEST" 
      "We couldn't find a route for you, please check your inputs."
    elsif ( @status == "OVER_QUERY_LIMIT" || @status == "REQUEST_DENIED" )
      "Something went wrong with our server. We're working to fix it!"
    elsif @status == "UNKNOWN_ERROR"
      "Something weird happened with the Google Maps request. Please try again!"
    elsif @start_waypoint == "locality"
      "Please enter a more specific startpoint."
    elsif @end_waypoint == "locality"
      "Please enter a more specific endpoint."
    elsif @route_tag == "1" || @route_tag == "2" || @route_tag == "3"
      "Just take the fucking subway."
    elsif /[A-Z]/.match(@route_tag)
      "Your trip is beyond the realm of the TTC. Godspeed."
    else
      false
    end
  end

  def self.plan_trip(startpoint,endpoint)
    @startpoint = startpoint
    @endpoint = endpoint
    @start_waypoint = nil
    @end_waypoint = nil

    @route_tag = nil


    if !error #Double checking the start and endpoints
      @api_url = api(@startpoint,@endpoint)

      @key = '&key=' + 'AIzaSyBfPfgP2xVhcjJ7btew8v7r1hBg-rjlEjE'
      total_transit_time = nil
      walk_response = get_walk_response
            
      transit_url = @api_url + 'transit' + '&transit_routing_preference=less_walking' + @key
      encoded = URI.encode(transit_url)
      @transit_response = HTTParty.get(encoded)
      @status = @transit_response["status"]
    end

    if !error #Checking for Google Maps error response
      walk_time = walk_response["routes"][0]["legs"][0]["duration"]["value"]
      @start_waypoint = @transit_response["geocoded_waypoints"][0]["types"][0]
      @end_waypoint = @transit_response["geocoded_waypoints"][1]["types"][0]
      if @transit_response["routes"].length > 0
        transit_time = @transit_response["routes"][0]["legs"][0]["duration"]["value"]
        step_one = @transit_response["routes"][0]["legs"][0]["steps"][0]["travel_mode"]
        start_lat = @transit_response["routes"][0]["legs"][0]["start_location"]["lat"]
        start_lng = @transit_response["routes"][0]["legs"][0]["start_location"]["lng"]
        end_lat = @transit_response["routes"][0]["legs"][0]["end_location"]["lat"]
        end_lng = @transit_response["routes"][0]["legs"][0]["end_location"]["lng"]
      end
        
      if step_one == "WALKING"
        instructions = @transit_response["routes"][0]["legs"][0]["steps"][0]["html_instructions"]
        if instructions.include? (" at ")
          ttc_stop = instructions.split("Walk to ")[1].gsub!(" at "," At ")
        else
          ttc_stop = instructions.split("Walk to ")[1]
        end
        @route_tag = @transit_response["routes"][0]["legs"][0]["steps"][1]["transit_details"]["line"]["short_name"]
        direction = @transit_response["routes"][0]["legs"][0]["steps"][1]["transit_details"]["headsign"].split(" - ")[0]
        @walk_to_stop_time = @transit_response["routes"][0]["legs"][0]["steps"][0]["duration"]["value"]
        lat = @transit_response["routes"][0]["legs"][0]["steps"][0]["end_location"]["lat"].to_s
        lng = @transit_response["routes"][0]["legs"][0]["steps"][0]["end_location"]["lng"].to_s
        display_end = HTTParty.get('https://maps.googleapis.com/maps/api/geocode/json?latlng=' + lat + ',' + lng + @key)["results"][0]["formatted_address"]
      elsif @transit_response["routes"][0]
        onboard = @transit_response["routes"][0]["legs"][0]["steps"][0]["transit_details"]["departure_stop"]["name"]
        if onboard.include? "Station"
          ttc_stop = onboard
        else
          ttc_stop = @transit_response["routes"][0]["legs"][0]["steps"][0]["transit_details"]["departure_stop"]["name"].gsub!(" at "," At ")
        end
        @route_tag = @transit_response["routes"][0]["legs"][0]["steps"][0]["transit_details"]["line"]["short_name"]
        direction = @transit_response["routes"][0]["legs"][0]["steps"][0]["transit_details"]["headsign"].split(" - ")[0]
        @walk_to_stop_time = 0
        display_end = HTTParty.get('https://maps.googleapis.com/maps/api/geocode/json?latlng=' + start_lat.to_s + ',' + start_lng.to_s + @key)["results"][0]["formatted_address"]
      end
    end
    
    if !error #Checking if route is bus or streetcar
      route_url = 'http://webservices.nextbus.com/service/publicXMLFeed?command=routeConfig&a=ttc&r=' + @route_tag
      routes = Nokogiri::HTML(open(route_url))
      stops = routes.xpath("//route//stop").to_s.split("</stop>")
      targets = []
      stop = nil
      stops.each do |s|
        if s.include? ttc_stop
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
        display_end = @destination
      end
    end

    if error
      response = {
        route_tag: "-",
        direction: "-",
        ttc_stop: "-", 
        vehicle_arrival: 0,
        walk_time: 0,
        walk_to_stop: "-",
        ride_time: 0, 
        transit_time: 0,
        take_transit: false,
        start_lat: "-",
        start_lng: "-",
        end_lat: "-",
        end_lng: "-",
        startpoint: "-",
        endpoint: "-",
        display_start: @origin,
        display_end: @destination,
        errors: error
      }
    else
      response = { 
        route_tag: @route_tag,
        direction: direction,
        ttc_stop: ttc_stop, 
        vehicle_arrival: arrival,
        walk_time: walk_time,
        walk_to_stop: @walk_to_stop_time,
        ride_time: transit_time, 
        transit_time: total_transit_time,
        take_transit: take_transit,
        start_lat: start_lat,
        start_lng: start_lng,
        end_lat: end_lat,
        end_lng: end_lng,
        startpoint: @startpoint,
        endpoint: @endpoint,
        display_start: @origin,
        display_end: @destination,
        errors: error
      }
    end
  end
end