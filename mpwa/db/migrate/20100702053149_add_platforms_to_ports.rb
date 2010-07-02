class AddPlatformsToPorts < ActiveRecord::Migration
  def self.up
    add_column :ports, :platforms, :string
  end

  def self.down
    remove_column :ports, :platforms
  end
end