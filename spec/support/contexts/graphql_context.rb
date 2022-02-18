# frozen_string_literal: true

RSpec.shared_context "graphql_context" do
  let(:query) { "" }
  let(:variables) { {} }
  let(:context) { {current_user: "user-0"} }

  subject(:result) do
    ApplicationSchema.execute(
      query,
      variables:,
      context:
    ).as_json
  end
end

RSpec.configure do |config|
  config.include_context "graphql_context", type: :graphql
end
