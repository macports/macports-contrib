ActionController::Routing::Routes.draw do |map|
  map.resources :ports do |port|
    port.resources :comments, :except => [:index, :show, :new]
  end

  map.index 'index', :controller => :pages, :action => :show, :page => :index
  map.install 'install', :controller => :pages, :action => :show, :page => :install
  map.contact 'contact', :controller => :pages, :action => :show, :page => :contact
  map.root :controller => :pages, :action => :show, :page => :index
end
