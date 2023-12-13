#!/usr/bin/env ruby

class Track
  attr_reader :segments, :name
  def initialize(args)
    @name = args[:name] || nil
    @segments = []
	insert_segment_objects(args[:segments])
  end
  
  def insert_segment_objects(segments)
    segments.each do |s|
      @segments.append(TrackSegment.new(s))
    end
  end

  def get_json()
    j = '{"type": "Feature", '
	
    if @name != nil
      j+= '"properties": {"title": "' + @name + '"},'
    end
	
    j += '"geometry": {"type": "MultiLineString","coordinates": ['
	
    # Loop through all the segment objects
    @segments.each_with_index do |s, index|
      if index > 0
        j += ","
      end
      j += '['
	  
      # Loop through all the coordinates in the segment
      tsj = ''
      s.coordinates.each do |c|
        if tsj != ''
          tsj += ','
        end
		
        # Add the coordinate
        tsj += '['
        tsj += "#{c.lon},#{c.lat}"
        if c.ele != nil
          tsj += ",#{c.ele}"
        end
		
        tsj += ']'
      end
	  
      j+= tsj + ']'
    end
	
    j + ']}}'
  end
  
end

class TrackSegment
  attr_reader :coordinates
  def initialize(coordinates)
    @coordinates = coordinates
  end
  
end

class Waypoint
  attr_reader :lat, :lon, :ele, :name, :type
  def initialize(args)
    @lat = args[:lat]
    @lon = args[:lon]
    @ele = args[:ele] || nil
    @name = args[:name] || nil
    @type = args[:type] || nil
  end

  def get_json(indent=0)
    j = '{"type": "Feature","geometry": {"type": "Point","coordinates": '
    # if name is not nil or type is not nil
    j += "[#{@lon},#{@lat}"
    
    if ele != nil
      j += ",#{@ele}"
    end
    
    j += ']},'
	
	if name != nil
      j += '"properties": {"title": "' + @name + '"'
    end
	
	if type != nil
	  if name != nil
	    j += ','
	  end
      j += '"icon": "' + @type + '"'  # type is the icon
    end
	
    if name != nil or type != nil
      j += '}'
	end
    
    j += "}"
	
    return j
  end
  
end

class World
  attr_reader :name, :features
  def initialize(args)
    @name = args[:name]
    @features = args[:features]
  end
  
  def add_feature(f)
    @features.append(t)
  end

  def to_geo_json(indent=0)
    # Write stuff
    s = '{"type": "FeatureCollection","features": ['
	
    @features.each_with_index do |f,i|
      if i != 0
        s +=","
      end
      	  
      s += f.get_json
    end
    
    s + "]}"
  end
end

def main()
  waypoint1 = Waypoint.new(:lat => -121.5, :lon => 45.5, :ele => 30,
    :name => "home", :type => "flag")
  waypoint2 = Waypoint.new(:lat => -121.5, :lon => 45.6,
    :name => "store", :type => "dot")
  
  segment1 = [
    Waypoint.new(:lat => -122, :lon => 45), 
	Waypoint.new(:lat => -122, :lon => 46), 
	Waypoint.new(:lat => -121, :lon => 46)
  ]
  segment2 = [
    Waypoint.new(:lat => -121, :lon => 45), 
	Waypoint.new(:lat => -121, :lon => 46)
  ]
  segment3 = [
    Waypoint.new(:lat => -121, :lon => 45.5), 
	Waypoint.new(:lat => -122, :lon => 45.5)
  ]

  track1 = Track.new(:segments => [segment1, segment2], :name => "track 1")
  track2 = Track.new(:segments => [segment3], :name => "track 2")

  world = World.new(
    :name => "My Data",
    :features => [waypoint1, waypoint2, track1, track2]
  )

  puts world.to_geo_json()
end

if File.identical?(__FILE__, $0)
  main()
end

