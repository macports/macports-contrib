class AddIndexToInstalledPorts < ActiveRecord::Migration
  def self.up
    add_index :installed_ports, :user_id
    add_index :installed_ports, :port_id
  end

  def self.down
    remove_index :installed_ports, :column => :user_id
    remove_index :installed_ports, :column => :port_id
  end
end
