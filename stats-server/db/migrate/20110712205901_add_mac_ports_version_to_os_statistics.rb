class AddMacPortsVersionToOsStatistics < ActiveRecord::Migration
  def self.up
    add_column :os_statistics, :macports_version, :string
  end

  def self.down
    remove_column :os_statistics, :macports_version
  end
end
