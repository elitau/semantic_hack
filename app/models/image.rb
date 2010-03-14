class Image
  include CouchPotato::Persistence
  property :flickr_data
  property :geoname_id
  
  view :geoname, :key => :geoname_id
  
  # 
  # def self.create_multiple(flickr_images)
  #   flickr_images.collect do |flickr_image|
  #     self.class.new(flickr_image.to_hash)
  #   end
  # end
  
  def save
    CouchPotato.database.save_document self
  end
  
  def self.find_by_geoname_id(geoname_id)
    CouchPotato.database.view Image.geoname(:key => geoname_id)
  end
  
  def self.create(attributes)
    self.new(attributes).save
  end
  
  def self.load(id)
    CouchPotato.database.load_document id
  end
  
end