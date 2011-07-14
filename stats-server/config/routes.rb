StatsServer::Application.routes.draw do
  
  get "home/index"

  resources :submissions

  resources :os_statistics
  
  resources :installed_ports
  
  resources :categories, :only => [:index] do
    match '/ports/page/:page', :to => 'ports#index', :page => :page
    resources :ports, :only => [:index, :show] 
      
  end

  match '/ports/page/:page', :to => 'ports#index', :page => :page
  resources :ports, :only => [:index, :search]
  match '/ports/search', :to => 'ports#search_generate', :as => :search_generate
  match '/ports/search/:criteria/:val/page/:page', :to => 'ports#search', :criteria => :criteria, :val => :val, :page => :page
  match '/ports/search/:criteria/:val', :to => 'ports#search', :criteria => :criteria, :val => :val, :as => :search
  
  root :to => 'home#index'
  
end
