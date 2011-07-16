class RemoveUuidFromInstalledPorts < ActiveRecord::Migration
  def self.up
    remove_column :installed_ports, :uuid
  end

  def self.down
    add_column :installed_ports, :uuid, :string
  end
end
