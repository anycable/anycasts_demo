require "rails_helper"
require Rails.root.join("spec", "schema_executor_shared_context")

describe Mutations::SendMessageMutation do
  include_context "schema executor"

  let!(:channels) { create_pair(:channel) }
  let(:channel_id) { channels.first.id }
  let(:input) { { content: "Hello" } }
  let(:variables) do
    { channelId: channel_id, input: input }
  end

  let(:query) do
    <<~GRAPHQL
      mutation sendMessage($channelId: ID!, $input: NewMessageInput!) {
        sendMessage(channelId: $channelId, input: $input) {
          message {
            content
          }
          errors {
            messages
            details
          }
        }
      }
    GRAPHQL
  end

  context "valid query" do
    let(:response) { result.dig("data", "sendMessage") }

    it "creates new message" do
      expect { result }.to change(Message, :count).by 1
      expect(Message.last.content).to eql variables[:input][:content]
    end

    it "has message field in response" do
      expect(response.key?("message")).to be
    end

    it "has null errors field" do
      expect(response["errors"]).not_to be
    end

    context "invalid id" do
      let(:channel_id) { -1 }

      it "has null message field" do
        expect(response["message"]).not_to be
      end
    end
  end

  context "invalid query" do
    let(:error_msg) do
      result.dig("errors")
            .first
            .dig("message")
    end

    context "invalid id arg" do
      let(:channel_id) { [] }

      it "returns an error" do
        expect(error_msg).to match /type ID! was provided invalid value$/
      end
    end

    context "invalid input arg" do
      context "received an extra argument" do
        let(:input) do
          { content: "Some", test: 1 }
        end

        it "returns an error" do
          expect(error_msg).to match /Field is not defined on NewMessageInput/
        end
      end

      context "missed required argument" do
        let(:input) { {} }

        it "returns an error" do
          expect(error_msg).to match /was provided invalid value for content/
        end
      end
    end
  end
end
