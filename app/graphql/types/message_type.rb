# frozen_string_literal: true

module Types
  class MessageType < Types::BaseObject
    field :author, String,
      description: "Message author",
      null: false
    field :content, String,
      description: "Message itself",
      null: false
    field :created_at, DateTime,
      description: "Message created_at timestamp",
      null: false
    field :updated_at, DateTime,
      description: "Message updated_at timestamp",
      null: false

    def author
      object.user.username
    end
  end
end
