ActionController::Routing::Routes.draw do |map|
  resources :categories, :only => [:index] do
    match '/ports/page/:page', :to => 'ports#index', :page => :page
    resources :ports, :only => [:index, :show] do
      resources :comments, :only => [:create, :destroy]
    end
  end

  match '/ports/page/:page', :to => 'ports#index', :page => :page
  resources :ports, :only => [:index, :search]
  match '/ports/search', :to => 'ports#search_generate', :as => :search_generate
  match '/ports/search/:criteria/:val/page/:page', :to => 'ports#search', :criteria => :criteria, :val => :val, :page => :page
  match '/ports/search/:criteria/:val', :to => 'ports#search', :criteria => :criteria, :val => :val, :as => :search

  match '/index', :to => 'pages#show', :page => :index, :as => :index
  match '/install', :to => 'pages#show', :page => :install, :as => :install
  match '/contact', :to => 'pages#show', :page => :contact, :as => :contact
  root :to => 'pages#show', :page => :index
end
