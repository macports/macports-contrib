ActionController::Routing::Routes.draw do |map|

  map.install 'install', :controller => :pages, :action => :show, :page => :install
  map.contact 'contact', :controller => :pages, :action => :show, :page => :contact
  map.ports 'ports', :controller => :pages, :action => :show, :page => :ports #temporary until the scaffolding is generated
  map.root :controller => :pages, :action => :show, :page => :index
end
