Rails.application.routes.draw do
  resources :channels, only: [:index, :show]
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  root "channels#index"
end
