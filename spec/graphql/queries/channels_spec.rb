# frozen_string_literal: true

require "rails_helper"

describe "{ channels { ... } } " do
  let!(:channels) { create_list(:channel, 3) }

  let(:query) do
    <<~GRAPHQL
      query getChannels {
        channels(first: 2) {
          nodes {
            name
          }
        }
      }
    GRAPHQL
  end

  it "returns specified number of channels" do
    expect(nodes.size).to eq(2)
    # Ordered by ID
    expect(nodes.map { _1["name"] }).to match_array(
      channels.take(2).map(&:name)
    )
  end
end
