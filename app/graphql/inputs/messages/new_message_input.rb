# frozen_string_literal: true

module Inputs
  module Messages
    class NewMessageInput < Types::BaseInputObject
      description "Attributes for creating/updating message"

      argument :content, String, description: "Message text"
    end
  end
end
