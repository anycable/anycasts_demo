Rails.application.routes.draw do
  post "/api/graphql", to: "graphql#execute"
  mount GraphqlPlayground::Rack.new, at: "/graphiql" if Rails.env.development?

  resources :channels, only: [:index, :show] do
    resources :messages, only: [:create]
  end
  root "channels#index"
end
