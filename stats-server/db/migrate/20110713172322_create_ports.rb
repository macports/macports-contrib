class CreatePorts < ActiveRecord::Migration
  def self.up
    create_table :ports do |t|
      t.string :name
      t.string :path
      t.string :version
      t.text :description
      t.string :licenses
      t.integer :category_id
      t.string :variants
      t.string :maintainers
      t.string :platforms
      t.string :categories

      t.timestamps
    end
  end

  def self.down
    drop_table :ports
  end
end
