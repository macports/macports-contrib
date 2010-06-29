class AddMaintainerToPorts < ActiveRecord::Migration
  def self.up
    add_column :ports, :maintainers, :string
  end

  def self.down
    remove_column :ports, :maintainers
  end
end