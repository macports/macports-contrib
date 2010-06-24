class FixSupplementalCategoryName < ActiveRecord::Migration
  def self.up
    rename_table :supplimental_categories, :supplemental_categories
  end

  def self.down
    rename_table :supplemental_categories, :supplimental_categories
  end
end