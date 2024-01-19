# frozen_string_literal: true

class ApplicationSchema < GraphQL::Schema
  use GraphQL::AnyCable, broadcast: true

  default_max_page_size 50

  mutation(Types::MutationType)
  query(Types::QueryType)
  subscription(Types::SubscriptionType)

  # For batch-loading (see https://graphql-ruby.org/dataloader/overview.html)
  use GraphQL::Dataloader
end
