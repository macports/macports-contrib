class AddIndexToOsStatistics < ActiveRecord::Migration
  def self.up
    add_index :os_statistics, :user_id
  end

  def self.down
    remove_index :os_statistics, :column => :user_id
  end
end
