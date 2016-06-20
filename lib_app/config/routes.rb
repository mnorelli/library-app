Rails.application.routes.draw do

  root 'users#index'

  get '/users', to: 'users#index', as: 'users'
  get '/users/new', to: 'users#new', as: 'new_user'
  post '/users', to: 'users#create'
  get '/users/:id', to: 'users#show'

  get '/sign_in', to: 'sessions#new'
  post '/sessions', to: 'sessions#create'

  get '/libraries', to: 'libraries#index', as: 'libraries'
  get "/libraries/new", to: "libraries#new", as: 'new_library'
  post '/libraries', to: 'libraries#create'
  get '/libraries/:id', to: 'libraries#show', as: 'show_library'
  post '/libraries/:id', to: 'libraries#edit', as: 'edit_library'
  delete '/libraries/:id', to: 'libraries#delete', as: 'delete_library'

end
