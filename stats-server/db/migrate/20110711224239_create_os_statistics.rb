class CreateOsStatistics < ActiveRecord::Migration
  def self.up
    create_table :os_statistics do |t|
      t.string :uuid
      t.string :osversion
      t.string :machine
      t.string :gccversion
      t.boolean :x11installed

      t.timestamps
    end
  end

  def self.down
    drop_table :os_statistics
  end
end
