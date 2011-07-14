class AddXCodeVersionToOsStatistics < ActiveRecord::Migration
  def self.up
    add_column :os_statistics, :xcode_version, :string
  end

  def self.down
    remove_column :os_statistics, :xcode_version
  end
end
