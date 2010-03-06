class CreateTravels < ActiveRecord::Migration
  def self.up
    create_table :travels do |t|

      t.timestamps
    end
  end

  def self.down
    drop_table :travels
  end
end
