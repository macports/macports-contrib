class UpdatePortForNewCategoryImplementation < ActiveRecord::Migration
  def self.up
    rename_column :ports, :categories, :category_id
    change_column :ports, :category_id, :integer
  end

  def self.down
    change_column :ports, :category_id, :string
    rename_column :ports, :category_id
  end
end