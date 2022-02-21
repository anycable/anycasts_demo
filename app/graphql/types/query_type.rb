# frozen_string_literal: true

module Types
  class QueryType < Types::BaseObject
    field :channel,
      Types::ChannelType,
      description: "Fetch channel by id with messages" do
      argument :id, ID, required: true
    end
    field :channels,
      Types::ChannelType.connection_type,
      description: "Returns a list of all channels with optional pages"

    def channels
      Channel.order(:id)
    end

    def channel(id:)
      Channel.find(id)
    end
  end
end
