# frozen_string_literal: true

module Types
  class MutationType < Types::BaseObject
    field :send_message,
      mutation: Mutations::Messages::SendMessageMutation,
      description: "Creates new message mutation"
  end
end
