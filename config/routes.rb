# frozen_string_literal: true

require Rails.root.join("lib", "graphql_playground", "rack")

Rails.application.routes.draw do
  get "/login" => "sessions#new", :as => :login
  post "/login" => "sessions#create"
  delete "/logout" => "sessions#destroy", :as => :logout

  resources :channels, only: [:index, :show] do
    resources :messages, only: [:create]
  end

  namespace :channels do
    resource :directs, only: [:create]
  end

  resources :profiles, only: [:show]

  root "channels#index"

  post "/api/graphql", to: "graphql#execute"
  if Rails.configuration.graphql_playground_enabled
    mount GraphQLPlayground::Rack.new, at: "/graphql"
  end
end
