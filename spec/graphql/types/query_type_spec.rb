# frozen_string_literal: true

require "rails_helper"

describe Types::QueryType do
  describe "channels" do
    context "mismatched connection type" do
      let(:query) do
        <<~GRAPHQL
          query getChannels {
            channels {
              name
            }
          }
        GRAPHQL
      end

      it "returns an error message" do
        expect(error_message).to match(/doesn't exist on type 'ChannelConnection'$/)
      end
    end
  end

  describe "channel" do
    context "invalid id" do
      let(:channel_id) { "test" }
      let(:query) do
        <<~GRAPHQL
          query getChannel {
            channel(id: #{channel_id}) {
              name
              messages {
                nodes {
                  content
                }
              }
            }
          }
        GRAPHQL
      end

      it "returns an error msg" do
        expect(error_message).to match(/Expected type 'ID!'\.$/)
      end

      context "missed id" do
        let(:query) do
          <<~GRAPHQL
            query getChannel {
              channel {
                name
                messages {
                  nodes {
                    content
                  }
                }
              }
            }
          GRAPHQL
        end

        it "returns an error msg" do
          expect(error_message).to match(/missing required arguments: id$/)
        end
      end

      context "id is bigger than last one" do
        let(:channel_id) { "-1" }

        it "raise an ActiveRecord error" do
          expect { result }.to raise_error(ActiveRecord::RecordNotFound)
        end
      end
    end
  end
end
