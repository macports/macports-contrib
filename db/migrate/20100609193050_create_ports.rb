class CreatePorts < ActiveRecord::Migration
  def self.up
    create_table :ports do |t|
      t.string :name
      t.string :path
      t.string :version
      t.text :description
      t.string :licenses
      t.string :categories
      t.string :variants

      t.timestamps
    end
  end

  def self.down
    drop_table :ports
  end
end
