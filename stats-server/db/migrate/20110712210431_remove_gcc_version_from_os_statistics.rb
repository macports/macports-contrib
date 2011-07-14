class RemoveGccVersionFromOsStatistics < ActiveRecord::Migration
  def self.up
    remove_column :os_statistics, :gccversion
  end

  def self.down
    add_column :os_statistics, :gccversion, :string
  end
end
