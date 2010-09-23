class Geoname < ActiveRecord::Base
  cattr_reader :per_page
  @@per_page = 20
  
  def place_id
    "#{self.asciiname.parameterize}-#{self.id}"
  end
  
  def resource_url
    "http://sws.geonames.org/#{geoname_id}/"
  end
  
  def to_s
    name
  end
  
end
