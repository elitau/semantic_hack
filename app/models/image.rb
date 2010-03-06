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


# property :lastupdate
# property :url_m
# property :width_m
# property :ispublic
# property :latitude
# property :place_id
# property :woeid
# property :width_sq
# property :height_m
# property :o_height
# property :o_width
# property :farm
# property :title
# property :height_sq
# property :url_o
# property :width_o
# property :license
# property :datetakengranularity
# property :accuracy
# property :url_sq
# property :height_o
# property :iconfarm
# property :pathalias
# property :server
# property :isfamily
# property :datetaken
# property :tags
# property :views
# property :dateupload
# property :media
# property :media_status
# property :width_s
# property :width_t
# property :url_s
# property :height_s
# property :longitude
# property :url_t
# property :height_t
# property :secret
# property :owner
# property :isfriend
# property :ownername
# property :iconserver
# property :machine_tags

# property :flickr_id