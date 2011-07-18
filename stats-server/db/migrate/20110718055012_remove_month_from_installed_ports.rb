class RemoveMonthFromInstalledPorts < ActiveRecord::Migration
  def self.up
    remove_column :installed_ports, :month
  end

  def self.down
    add_column :installed_ports, :month, :integer
  end
end
