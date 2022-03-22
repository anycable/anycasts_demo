# frozen_string_literal: true

require "rails_helper"

describe Mutations::Messages::SendMessageMutation do
  let(:channel) { create(:channel) }
  let(:input) { {content: "Hello"} }

  let(:variables) do
    {channel_id: channel.id, input: input}
  end

  let(:query) do
    <<~GRAPHQL
      mutation sendMessage($channel_id: ID!, $input: NewMessageInput!) {
        sendMessage(channelId: $channel_id, input: $input) {
          message {
            content
          }
          errors {
            fullMessages
            details
          }
        }
      }
    GRAPHQL
  end

  it "creates new message" do
    expect { subject }.to change(channel.messages, :count).by(1)
    expect(data["message"]["content"]).to eq("Hello")
  end

  context "invalid id" do
    let(:channel_id) { "-1" }

    it "has null message field" do
      expect(result["message"]).to be_nil
    end
  end

  context "missing required arguments" do
    let(:input) { {} }

    it "returns an error" do
      expect(error_message).to match(/was provided invalid value for content/)
    end
  end
end
