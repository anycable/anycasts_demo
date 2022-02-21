# frozen_string_literal: true

module Types
  class ValidationErrorsType < Types::BaseObject
    description <<~DESC
      Represents validation errors
      (wrapper over ActiveModel::Errors
      https://api.rubyonrails.org/classes/ActiveModel/Errors.html)
    DESC

    field :details, String, "JSON-encoded map of attribute -> error ids", null: false
    field :full_messages, [String], "Human-friendly error messages", null: false

    def details
      object.details.as_json
    end
  end
end
