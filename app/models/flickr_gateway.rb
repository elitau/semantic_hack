class FlickrGateway
  
  @last_request_at = Time.now
  
  def self.search_for_geoname(geoname)
    images = local_search_for_geoname(geoname)
    if images.empty?
      sleep(1.2) if @last_request_at > Time.now - 1.5.seconds
      @last_request_at = Time.now
      images = flickr_search_with_lat_long(geoname.latitude, geoname.longitude)
      create_local_db_images(images, geoname)
      images
    end
    inject_attributes(images)
  end
  
  def self.local_search_for_geoname(geoname)
    local_images = Image.find_by_geoname_id(geoname.geoname_id)
    local_images.collect do |local_image|
      FlickRaw::Response.new(local_image.flickr_data, "photo")
    end
  end
  
  def self.flickr_search_with_lat_long(lat, lon, radius = 3, amount = 3)
    images = flickr.photos.search :lat => lat, 
      :lon            => lon,
      :radius         => radius,
      :min_taken_date => '1800-01-01 00:00:00',
      :per_page       => amount,
      :extras         => 'license, date_upload, date_taken, owner_name, icon_server, original_format, last_update, geo, tags, machine_tags, o_dims, views, media, path_alias, url_sq, url_t, url_s, url_m, url_o'
  end
  
  def self.inject_attributes(images)
    images.each do |image|
      image.extend DirectFlickrApi
    end
  end

  def self.create_local_db_images(images, geoname)
    images.each do |image|
      Image.create(:flickr_data => image.to_hash, :geoname_id => geoname.geoname_id)
    end
  end
  
end

module DirectFlickrApi
  def small_url
    self.url_s
  end
  
  def url
    "http://www.flickr.com/photos/#{self.pathalias}/#{self.id}/"
  end
end

