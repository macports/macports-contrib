class AddGccVersionToOsStatistics < ActiveRecord::Migration
  def self.up
    add_column :os_statistics, :gcc_version, :string
  end

  def self.down
    remove_column :os_statistics, :gcc_version
  end
end
