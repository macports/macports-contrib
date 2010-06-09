class CreatePortDependencies < ActiveRecord::Migration
  def self.up
    create_table :port_dependencies do |t|
      t.integer :port_id
      t.integer :dependency_id

      t.timestamps
    end
  end

  def self.down
    drop_table :port_dependencies
  end
end
