class CategoriesController < ApplicationController
  caches_page :index

  def index
    @categories = Category.all(:order => 'name ASC')
  end
end
