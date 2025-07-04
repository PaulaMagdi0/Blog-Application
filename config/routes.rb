require "sidekiq/web"
Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  post 'signup', to: 'authentication#signup'
  post 'login', to: 'authentication#login'
  put    'users/:id',   to: 'authentication#update'
  delete 'users/:id',   to: 'authentication#destroy'
  resources :posts, only: [:index, :show, :create, :update, :destroy] do
    resources :comments, only: [:index, :create, :update, :destroy]
  end
  get "up" => "rails/health#show", as: :rails_health_check
  mount Sidekiq::Web => "/sidekiq"

  # Defines the root path route ("/")
  # root "posts#index"
end
