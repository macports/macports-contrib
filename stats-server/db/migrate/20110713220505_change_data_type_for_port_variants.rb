class ChangeDataTypeForPortVariants < ActiveRecord::Migration
  def self.up
    change_table :ports do |t|
      t.change :variants, :text, :limit => nil
    end
  end

  def self.down
    change_table :ports do |t|
      t.change :variants, :string
    end
  end
end