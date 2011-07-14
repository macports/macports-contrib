class AddOsxVersionToOsStatistics < ActiveRecord::Migration
  def self.up
    add_column :os_statistics, :osx_version, :string
  end

  def self.down
    remove_column :os_statistics, :osx_version
  end
end
