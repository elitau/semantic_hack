class CreateGeonames < ActiveRecord::Migration
  def self.up
    create_table :geonames do |t|
      t.integer :geoname_id
      t.string :name              # name of geographical point (utf8) varchar(200)
      t.string :asciiname         # name of geographical point in plain ascii characters, varchar(200)
      # t.string :alternatenames    # alternatenames, comma separated varchar(5000)
      t.float :latitude           # latitude in decimal degrees (wgs84)
      t.float :longitude          # longitude in decimal degrees (wgs84)
      t.string :timezone          # the timezone id (see file timeZone.txt)
    end
  end

  def self.down
    drop_table :geonames
  end
end
