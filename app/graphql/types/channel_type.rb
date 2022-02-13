# frozen_string_literal: true

module Types
  class ChannelType < Types::BaseObject
    field :name, String
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false
    field :messages,
          Types::MessageType.connection_type,
          description: 'Returns all messages in channels',
          null: true
  end
end
