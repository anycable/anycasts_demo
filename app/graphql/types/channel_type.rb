# frozen_string_literal: true

module Types
  class ChannelType < Types::BaseObject
    field :created_at, DateTime, null: false,
      description: "Created at timestamp"
    field :messages,
      MessageType.connection_type,
      description: "Returns all messages in channels"
    field :name, String, description: "Name of channel"
    field :updated_at, DateTime, description: "Updated at timestamp", null: false
  end
end
