class Message < ApplicationRecord
  belongs_to :channel, touch: true
  belongs_to :user

  after_commit on: :create do
    AnyCable::Rails.broadcasting_to_others do
      broadcast_append_to channel, partial: "messages/message", locals: {message: self}, target: "messages"
    end
  end
end
