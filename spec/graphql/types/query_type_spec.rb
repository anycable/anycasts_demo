require "rails_helper"

RSpec.describe Types::QueryType do
  let!(:channels) { create_list(:channel, 5) }
  let!(:messages) { create_list(:message, 5, channel: channels.first) }
  let(:error_message) do
    result.dig("errors")
          .first
          .dig("message")
  end

  subject(:result) do
    AnycastsDemoSchema.execute(query).as_json
  end

  describe "channels" do
    context "query matches schema" do
      let(:query) do
        %(query getChannels {
          channels {
            nodes {
              name
            }
          }
        })
      end

      let(:result_channels) { result.dig("data", "channels") }
      let(:result_channels_names) do
        result_channels.dig("nodes").pluck("name")
      end

      it "returns all channel's name" do
        expect(result_channels_names).to match_array(channels.pluck(:name))
      end

      it "has nodes field in result" do
        expect(result_channels.size).to eql 1
        expect(result_channels.key?("nodes")).to be
      end

      context "with messages field present in query" do
        let(:query) do
          %(query getChannels {
            channels {
              nodes {
                name
                messages {
                  nodes {
                    content
                  }
                }
              }
            }
          })
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

        it "returns messages content" do
          expect(expected_messages_content).to match_array(resulted_messages_content)
        end
      end

      context "paginate result" do
        let(:channels) { create_list(:channel, 55) }

        it "returns only max channels per page" do
          expect(result_channels_names.size).to eql AnycastsDemoSchema.default_max_page_size
        end
      end

      context "with first param" do
        let(:num_of_channels) { 2 }
        let(:params) { "first: #{num_of_channels}" }
        let(:query) do
          %(query getChannels {
            channels(#{params}) {
              nodes {
                name
              }
            }
          })
        end

        let(:queried_channels_names) { channels.last(2).pluck(:name) }

        it "returns only specified channels" do
          expect(result_channels_names.size).to eql num_of_channels
          expect(queried_channels_names).to match_array(result_channels_names)
        end
      end
    end

    context "invalid query" do
      context "mismatched connection type" do
        let(:query) do
          %(query getChannels {
            channels {
              name
            }
          })
        end

        it "returns an error message" do
          expect(error_message).to match(/doesn't exist on type 'ChannelConnection'$/)
        end
      end

      context "mismatched channel type" do
        let(:query) do
          %(query getChannels {
            channels {
              nodes {
                id
                name
              }
            }
          })
        end

        it "returns an error message" do
          expect(error_message).to match(/doesn't exist on type 'Channel'$/)
        end
      end
    end
  end

  describe "channel" do
    let(:result_channel) { result.dig("data", "channel") }

    context "valid query" do
      let(:channel_id) { channels.first.id }
      let(:message_count) { 3 }
      let(:query) do
        %(query getChannel {
            channel(id: #{channel_id}) {
              name
              messages(last: #{message_count}) {
                nodes {
                  content
                }
              }
            }
          }
        )
      end

      let(:expected_channel_name) { Channel.find(channel_id).name }
      let(:queried_messages) { result_channel.dig("messages", "nodes") }
      let(:queried_messages_content) { queried_messages.pluck("content") }
      let(:expected_messages_content) do
        Message.where(channel_id: channel_id)
               .first(message_count)
               .pluck(:content)
      end

      it "returns channel with message" do
        expect(result_channel["name"]).to eql(expected_channel_name)
        expect(queried_messages.size).to eql message_count
        expect(queried_messages_content).to contain_exactly(*expected_messages_content)
      end
    end

    context "invalid query" do
      context "invalid id" do
        let(:channel_id) { "test" }
        let(:query) do
          %(query getChannel {
              channel(id: #{channel_id}) {
                name
                messages {
                  nodes {
                    content
                  }
                }
              }
            }
          )
        end

        it "returns an error msg" do
          expect(error_message).to match(/Expected type 'ID!'\.$/)
        end

        context "id is bigger than last one" do
          let(:channel_id) { channels.last.id + 1 }

          it "raise an ActiveRecord error" do
            expect { result }.to raise_error(ActiveRecord::RecordNotFound)
          end
        end
      end

      context "invalid schema format" do
        let(:query) do
          %(query getChannel {
            channel(id: 1) {
              name
              messages {
                content
              }
            }
          }
        )
        end

        it "returns an error" do
          expect(error_message).to match /doesn't exist on type 'MessageConnection'$/
        end
      end
    end
  end
end
