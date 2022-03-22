# frozen_string_literal: true

require "rails_helper"

describe Types::ChannelType do
  context "invalid schema format" do
    let(:query) do
      <<~GRAPHQL
        query getChannel {
          channel(id: 1) {
            name
            messages {
              content
            }
          }
        }
      GRAPHQL
    end

    it "returns an error" do
      expect(error_message).to match(/doesn't exist on type 'MessageConnection'$/)
    end

    context "mismatched channel type" do
      let(:query) do
        <<~GRAPHQL
          query getChannels {
            channels {
              nodes {
                id
                name
              }
            }
          }
        GRAPHQL
      end

      it "returns an error message" do
        expect(error_message).to match(/doesn't exist on type 'Channel'$/)
      end
    end
  end
end
