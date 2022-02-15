RSpec.shared_context "schema executor" do
  let(:query) { "" }
  let(:variables) { {} }

  subject(:result) do
    ApplicationSchema.execute(
      query,
      variables: variables,
      context: {current_user: "user-0"}
    ).as_json
  end
end
