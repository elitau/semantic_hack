class Geoname < ActiveRecord::Base
  
  def place_id
    "#{self.asciiname.parameterize}-#{self.id}"
  end
  
end
