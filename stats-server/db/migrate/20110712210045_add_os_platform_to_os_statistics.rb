class AddOsPlatformToOsStatistics < ActiveRecord::Migration
  def self.up
    add_column :os_statistics, :os_platform, :string
  end

  def self.down
    remove_column :os_statistics, :os_platform
  end
end
