# frozen_string_literal: true

class ApplicationSchema < GraphQL::Schema
  default_max_page_size 50
  max_complexity 1000
  max_depth 8

  mutation(Types::MutationType)
  query(Types::QueryType)

  # For batch-loading (see https://graphql-ruby.org/dataloader/overview.html)
  use GraphQL::Dataloader
end
