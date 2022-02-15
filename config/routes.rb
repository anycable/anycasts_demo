require Rails.root.join("lib", "graphql_playground", "rack")

Rails.application.routes.draw do
  post "/api/graphql", to: "graphql#execute"
  if Rails.env.development? # rubocop:disable Lint/Env
    mount GraphQLPlayground::Rack.new, at: "/graphql"
  end

  resources :channels, only: [:index, :show] do
    resources :messages, only: [:create]
  end
  root "channels#index"
end
