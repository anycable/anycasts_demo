# frozen_string_literal: true

module Mutations
  module Messages
    class SendMessageMutation < Mutations::BaseMutation
      description "Creates new message"

      argument :channel_id, ID, required: true, description: "ID of associated channel"
      argument :input, Inputs::Messages::NewMessageInput, required: true, description: "Message attributes"

      field :errors, Types::ValidationErrorsType,
        null: true,
        description: "Validation errors that occurs while saving"
      field :message, Types::MessageType, null: true,
        description: "Just created message"

      def resolve(channel_id:, input:)
        message = Message.new(input.to_h)
        message.channel_id = channel_id
        message.user = current_user

        if message.save
          {message:}
        else
          {errors: message.errors}
        end
      end
    end
  end
end
