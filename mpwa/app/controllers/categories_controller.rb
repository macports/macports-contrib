class CategoriesController < ApplicationController
  def index
    @categories = Category.all(:order => 'name ASC')
    @updated = Port.all(:order => 'updated_at DESC', :limit => 1).first.updated_at
  end
end
