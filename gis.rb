#!/usr/bin/env ruby

class Track
  def initialize(segments, name=nil)
    @name = name
    @segments = []
	insert_segment_objects(segments)
  end
  
  def insert_segment_objects(segments)
    segments.each do |s|
      @segments.append(TrackSegment.new(s))
    end
  end

  def get_track_json()
    j = '{'
    j += '"type": "Feature", '
    if @name != nil
      j+= '"properties": {'
      j += '"title": "' + @name + '"'
      j += '},'
    end
    j += '"geometry": {'
    j += '"type": "MultiLineString",'
    j +='"coordinates": ['
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
      j+=tsj
      j+=']'
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

class Point
  attr_reader :lat, :lon, :ele
  def initialize(lon, lat, ele=nil)
    @lon = lon
    @lat = lat
    @ele = ele
  end
  
end

class Waypoint
  attr_reader :lat, :lon, :ele, :name, :type
  def initialize(lon, lat, ele=nil, name=nil, type=nil)
    @lat = lat
    @lon = lon
    @ele = ele
    @name = name
    @type = type
  end

  def get_waypoint_json(indent=0)
    j = '{"type": "Feature",'
    # if name is not nil or type is not nil
    j += '"geometry": {"type": "Point","coordinates": '
    j += "[#{@lon},#{@lat}"
    if ele != nil
      j += ",#{@ele}"
    end
    j += ']},'
    if name != nil or type != nil
      j += '"properties": {'
      if name != nil
        j += '"title": "' + @name + '"'
      end
      if type != nil  # if type is not nil
        if name != nil
          j += ','
        end
        j += '"icon": "' + @type + '"'  # type is the icon
      end
      j += '}'
    end
    j += "}"
    return j
  end
  
end

class World
  def initialize(name, features)
    @name = name
    @features = features
  end
  
  def add_feature(f)
    @features.append(t)
  end

  def to_geojson(indent=0)
    # Write stuff
    s = '{"type": "FeatureCollection","features": ['
	
    @features.each_with_index do |f,i|
      if i != 0
        s +=","
      end
	  
      if f.class == Track
        s += f.get_track_json
      elsif f.class == Waypoint
        s += f.get_waypoint_json
      end
    end
	
    s + "]}"
  end
end

def main()
  waypoint1 = Waypoint.new(-121.5, 45.5, 30, "home", "flag")
  waypoint2 = Waypoint.new(-121.5, 45.6, nil, "store", "dot")
  
  segment1 = [Point.new(-122, 45), Point.new(-122, 46), Point.new(-121, 46)]
  segment2 = [Point.new(-121, 45), Point.new(-121, 46)]
  segment3 = [Point.new(-121, 45.5), Point.new(-122, 45.5)]

  track1 = Track.new([segment1, segment2], "track 1")
  track2 = Track.new([segment3], "track 2")

  world = World.new("My Data", [waypoint1, waypoint2, track1, track2])

  puts world.to_geojson()
end

if File.identical?(__FILE__, $0)
  main()
end

