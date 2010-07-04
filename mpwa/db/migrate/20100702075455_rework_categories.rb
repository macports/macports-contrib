class ReworkCategories < ActiveRecord::Migration
  def self.up
    drop_table :supplemental_categories
    add_column :ports, :categories, :string
  end

  def self.down
    remove_column :ports, :categories
    create_table :supplemental_categories do |t|
      t.string :name
      t.integer :port_id

      t.timestamps
    end
  end
end