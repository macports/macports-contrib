class AddIndexToPorts < ActiveRecord::Migration
  def self.up
    add_index :ports, :name
  end

  def self.down
    remove_index :ports, :column => :name
  end
end
