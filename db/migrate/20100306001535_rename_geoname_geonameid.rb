class RenameGeonameGeonameid < ActiveRecord::Migration
  def self.up
    rename_column :geonames, :geonameid, :geoname_id
  end

  def self.down
    rename_column :geonames, :geoname_id, :geonameid
  end
end
