class Message < ApplicationRecord
  belongs_to :channel, touch: true
  belongs_to :user

  after_commit on: :create do
    broadcast_append_to channel, partial: "messages/message", locals: {message: self}, target: "messages"
  end
end
