module Subscriptions
  class MessageAdded < Subscriptions::BaseSubscription
    description "Subscription triggers when a new message is added to a channel"

    argument :a, String, required: false
    argument :b, String, required: false
    argument :c, String, required: false
    argument :channel_id, ID, required: true
    argument :d, String, required: false

    field :message, Types::MessageType, null: true

    def subscribe(channel_id:, **)
      channel = Channel.find(channel_id)
      {message: channel.messages.last}
    end

    def update
      {message: object}
    end
  end
end
