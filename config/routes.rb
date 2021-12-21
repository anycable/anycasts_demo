Rails.application.routes.draw do
  resources :channels, only: [:index, :show] do
    resources :messages, only: [:create]
  end
  root "channels#index"
end
