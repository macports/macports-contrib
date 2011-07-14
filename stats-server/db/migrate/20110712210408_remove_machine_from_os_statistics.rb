class RemoveMachineFromOsStatistics < ActiveRecord::Migration
  def self.up
    remove_column :os_statistics, :machine
  end

  def self.down
    add_column :os_statistics, :machine, :string
  end
end
