class AddUserIdToOsStatistics < ActiveRecord::Migration
  def self.up
    add_column :os_statistics, :user_id, :integer
  end

  def self.down
    remove_column :os_statistics, :user_id
  end
end
