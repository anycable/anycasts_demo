# frozen_string_literal: true

RSpec.shared_context "graphql_context" do
  let(:user) { create(:user) }
  let(:query) { "" }
  let(:variables) { {} }
  let(:context) { {current_user: user} }
  let(:field) { result.fetch("data").keys.first }

  subject(:result) do
    ApplicationSchema.execute(
      query,
      variables:,
      context:
    ).as_json
  end

  let(:data) do
    raise "API Query failed:\n\tquery: #{query}\n\terrors: #{result["errors"]}" if result.key?("errors")
    result.fetch("data").dig(*field.split("->"))
  end

  let(:nodes) { data.fetch("nodes") }
  let(:edges) { data.fetch("edges").map { |node| node.fetch("node") } }
  let(:page_info) { data.fetch("pageInfo") }

  let(:error_message) do
    result.dig("errors")&.first&.dig("message")
  end
end

RSpec.configure do |config|
  config.include_context "graphql_context", type: :graphql
end
