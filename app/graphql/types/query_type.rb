module Types
  class QueryType < Types::BaseObject
    field :channels,
          Types::ChannelType.connection_type,
          description: "Returns a list of all channels with optional pages"
    field :channel,
          Types::ChannelType,
          description: "Fetch channel by id with messages" do
      argument :id, ID, required: true
    end

    def channels
      Channel.preload(:messages).order(id: :desc)
    end

    def channel(id:)
      Channel.find(id)
    end
  end
end
