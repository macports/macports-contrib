class AddBuildArchToOsStatistics < ActiveRecord::Migration
  def self.up
    add_column :os_statistics, :build_arch, :string
  end

  def self.down
    remove_column :os_statistics, :build_arch
  end
end
