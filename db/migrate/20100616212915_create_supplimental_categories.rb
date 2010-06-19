class CreateSupplimentalCategories < ActiveRecord::Migration
  def self.up
    create_table :supplimental_categories do |t|
      t.string :name
      t.integer :port_id

      t.timestamps
    end
  end

  def self.down
    drop_table :supplimental_categories
  end
end
