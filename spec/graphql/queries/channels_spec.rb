# frozen_string_literal: true

require "rails_helper"

RSpec.describe "{ channels { ... } } ", type: :graphql do
  let(:channels_count) { 5 }
  let(:channels) { Channel.order(:id).first(channels_count) }
  let(:error_message) do
    result.dig("errors")
      .first
      .dig("message")
  end

  context "query matches schema" do
    let(:query) do
      <<~GRAPHQL
        query getChannels {
          channels(first: #{channels_count}) {
            nodes {
              name
            }
          }
        }
      GRAPHQL
    end

    let(:result_channels) { result.dig("data", "channels") }
    let(:result_channels_names) do
      result_channels.dig("nodes").pluck("name")
    end

    let(:channel_names) { channels.pluck(:name) }

    it "returns channels names" do
      expect(channel_names).to match_array(result_channels_names)
    end

    context "with messages field present in query" do
      let(:query) do
        <<~GRAPHQL
          query getChannels {
            channels(first: #{channels_count}) {
              nodes {
                name
                messages {
                  nodes {
                    content
                  }
                }
              }
            }
          }
        GRAPHQL
      end

      let(:expected_messages_content) do
        Message.where(channels: channels)
          .pluck(:content)
      end

      let(:resulted_messages_content) do
        result_channels.dig("nodes")
          .pluck("messages")
          .pluck("nodes")
          .flatten
          .pluck("content")
      end

      it "returns some channel's messages content" do
        expect(resulted_messages_content - expected_messages_content).to eql []
      end
    end

    context "paginate result" do
      before { create_list(:channel, max_page_size + 1) }

      let(:max_page_size) { ApplicationSchema.default_max_page_size }
      let(:query) do
        <<~GRAPHQL
          query getChannels {
            channels {
              nodes {
                name
              }
            }
          }
        GRAPHQL
      end

      it "returns only max channels per page" do
        expect(result_channels_names.size).to eql max_page_size
      end
    end
  end
end
