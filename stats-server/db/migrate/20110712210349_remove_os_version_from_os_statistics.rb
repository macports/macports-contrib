class RemoveOsVersionFromOsStatistics < ActiveRecord::Migration
  def self.up
    remove_column :os_statistics, :osversion
  end

  def self.down
    add_column :os_statistics, :osversion, :string
  end
end
