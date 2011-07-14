class ChangeDataTypeForInstalledPortVariants < ActiveRecord::Migration
  def self.up
    change_table :installed_ports do |t|
      t.change :variants, :text, :limit => nil
    end
  end

  def self.down
    change_table :installed_ports do |t|
      t.change :variants, :string
    end
  end
end