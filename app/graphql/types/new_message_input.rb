# frozen_string_literal: true

module Types
  class NewMessageInput < Types::BaseInputObject
    argument :content, String
  end
end
