class RemoveYearFromInstalledPorts < ActiveRecord::Migration
  def self.up
    remove_column :installed_ports, :year
  end

  def self.down
    add_column :installed_ports, :year, :integer
  end
end
