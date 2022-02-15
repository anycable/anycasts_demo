module Types
  class ValidationErrorsType < Types::BaseObject
    description <<~DESC
      Represents validation errors
      (wrapper over ActiveModel::Errors
      https://api.rubyonrails.org/classes/ActiveModel/Errors.html)
    DESC

    field :details, String, "JSON-encoded map of attribute -> error ids", null: false
    # rubocop:disable GraphQL/FieldMethod
    field :messages, [String], "Human-friendly error messages", null: false
    # rubocop:enable GraphQL/FieldMethod

    def messages
      object.full_messages
    end

    def details
      object.details.as_json
    end
  end
end
