class RemoveUuidFromOsStatistics < ActiveRecord::Migration
  def self.up
    remove_column :os_statistics, :uuid
  end

  def self.down
    add_column :os_statistics, :uuid, :string
  end
end