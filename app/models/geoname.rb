class Geoname < ActiveRecord::Base
  
  def place_id
    "#{self.asciiname.parameterize}-#{self.id}"
  end
  
  def resource_url
    "http://sws.geonames.org/#{geoname_id}/"
  end
  
end
