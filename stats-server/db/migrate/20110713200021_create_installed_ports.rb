class CreateInstalledPorts < ActiveRecord::Migration
  def self.up
    create_table :installed_ports do |t|
      t.string :uuid
      t.integer :port_id
      t.string :version
      t.string :variants
      t.string :month
      t.string :year

      t.timestamps
    end
  end

  def self.down
    drop_table :installed_ports
  end
end
