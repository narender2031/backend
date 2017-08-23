Rails.application.routes.draw do
      mount API => '/'
    get '/docs' => redirect('/swagger-ui/dist/index.html?url=/swagger_docs')
  namespace :opi do
    get '/invites', to: 'invites#index'
    post '/invites', to: 'invites#create'
    get '/locations', to:'locations#index'
    post '/locations', to: 'locations#create'
    get '/users', to: 'auth#index'
    post '/facebook', to: 'auth#facebook'
    get '/reviews', to: 'reviews#index'
    post '/facebook_location', to: 'locations#facebook'
    get '/yelp_reviews', to: 'reviews#yelp_review'
    post '/facebook_short_link', to: 'reviews#facebook_short_link'
    post '/set_location', to: 'locations#set_location'
  end
  get '/login', to: 'sessions#new'
  post '/login', to: 'sessions#create'
  get '/settings', to: 'teams#edit'
  get '/reviews', to: 'reviews#index'
  get '/l_reviews', to: 'page#dash'
  get '/analytics', to: 'analytics#index'
  get '/logout', to: 'sessions#destroy'


  
  resources :locations
  resources :invites
  resources :teams
  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)
  root 'pages#dash'

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
