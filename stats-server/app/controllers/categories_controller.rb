class CategoriesController < ApplicationController
	caches_page :index
	cache_sweeper :category_sweeper, :only => [:create, :update, :destroy]

	def index
		@categories = Category.all(:order => 'name ASC')
	end
end
