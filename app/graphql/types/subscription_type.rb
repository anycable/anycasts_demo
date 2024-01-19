module Types
  class SubscriptionType < Types::BaseObject
    field :message_added, subscription: Subscriptions::MessageAdded
  end
end
