class AddOsArchToOsStatistics < ActiveRecord::Migration
  def self.up
    add_column :os_statistics, :os_arch, :string
  end

  def self.down
    remove_column :os_statistics, :os_arch
  end
end
