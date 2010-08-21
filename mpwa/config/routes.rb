ActionController::Routing::Routes.draw do |map|
  map.resources :categories, :only => [:index] do |category|
    category.resources :ports, :only => [:index, :show] do |port|
      port.resources :comments, :only => [:new, :create]
    end
    category.connect '/ports/page/:page', :controller => :ports, :action => :index, :page => :page
  end

  map.connect '/ports/page/:page', :controller => :ports, :action => :index, :page => :page
  map.resources :ports, :only => [:index, :search]
  map.search_generate 'ports/search', :controller => :ports, :action => :search_generate
  map.connect '/ports/search/:criteria/:val/page/:page', :controller => :ports, :action => :search, :criteria => :criteria, :val => :val, :page => :page
  map.search '/ports/search/:criteria/:val', :controller => :ports, :action => :search, :criteria => :criteria, :val => :val

  map.index 'index', :controller => :pages, :action => :show, :page => :index
  map.install 'install', :controller => :pages, :action => :show, :page => :install
  map.contact 'contact', :controller => :pages, :action => :show, :page => :contact
  map.root :controller => :pages, :action => :show, :page => :index
end
