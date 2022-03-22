# frozen_string_literal: true

require "rails_helper"

describe "{ channel { ... } } " do
  context "valid query" do
    let(:channel) { create(:channel) }
    let!(:messages) { create_list(:message, 3, channel: channel) }
    let(:variables) { {channel_id: channel.id} }

    let(:query) do
      <<~GRAPHQL
        query getChannel($channel_id: ID!) {
          channel(id: $channel_id) {
            name
            messages(last: 2) {
              nodes {
                content
              }
            }
          }
        }
      GRAPHQL
    end

    it "returns channel with messages" do
      expect(data["name"]).to eq(channel.name)
      expect(data["messages"]["nodes"].size).to eq(2)
    end
  end
end
