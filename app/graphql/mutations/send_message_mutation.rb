module Mutations
  class SendMessageMutation < Mutations::BaseMutation
    argument :channel_id, ID, required: true
    argument :input, Types::NewMessageInput, required: true

    field :message, Types::MessageType, null: true
    field :errors, [String], null: true

    def resolve(**args)
      message = Message.new(args[:input].to_h)
      message[:channel_id] = args[:channel_id]
      message[:author] = context[:current_user]

      if message.save
        { message: message }
      else
        { errors: message.errors.full_messages }
      end
    end
  end
end
