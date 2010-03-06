class AddLastCheckedToGeonames < ActiveRecord::Migration
  def self.up
    add_column :geonames, :last_flickr_check, :datetime
    add_column :geonames, :found_images, :integer
  end

  def self.down
    remove_column :geonames, :found_images
    remove_column :geonames, :last_flickr_check
  end
end
