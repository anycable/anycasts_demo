# frozen_string_literal: true

require "rails_helper"

RSpec.describe "{ channel { ... } } ", type: :graphql do
  let(:result_channel) { result.dig("data", "channel") }

  context "valid query" do
    let(:channel_id) { Channel.first.id }
    let(:message_count) { 3 }
    let(:query) do
      <<~GRAPHQL
        query getChannel {
          channel(id: #{channel_id}) {
            name
            messages(last: #{message_count}) {
              nodes {
                content
              }
            }
          }
        }
      GRAPHQL
    end

    let(:expected_channel_name) { Channel.find(channel_id).name }
    let(:queried_messages_content) do
      result_channel.dig("messages", "nodes")
        .pluck("content")
    end

    let(:expected_messages_content) do
      Message.where(channel_id: channel_id)
        .first(message_count)
        .pluck(:content)
    end

    it "returns channel with message" do
      expect(result_channel["name"]).to eql(expected_channel_name)
      expect(queried_messages_content.size).to eql message_count
      expect(queried_messages_content).to contain_exactly(*expected_messages_content)
    end
  end
end
