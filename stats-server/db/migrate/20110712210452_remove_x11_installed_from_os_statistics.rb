class RemoveX11InstalledFromOsStatistics < ActiveRecord::Migration
  def self.up
    remove_column :os_statistics, :x11installed
  end

  def self.down
    add_column :os_statistics, :x11installed, :string
  end
end
