# frozen_string_literal: true

module Types
  class ChannelType < Types::BaseObject
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false,
      description: "Created at timestamp"
    field :messages,
      Types::MessageType.connection_type,
      description: "Returns all messages in channels"
    field :name, String, description: "Name of channel"
    field :updated_at, GraphQL::Types::ISO8601DateTime, description: "Updated at timestamp", null: false
  end
end
