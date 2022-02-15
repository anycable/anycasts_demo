class Message < ApplicationRecord
  belongs_to :channel

  validates :content, presence: true

  after_commit on: :create do
    broadcast_append_to channel, partial: "messages/message", locals: {message: self}, target: "messages"
  end
end
