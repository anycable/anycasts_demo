class Message < ApplicationRecord
  belongs_to :channel, touch: true
  belongs_to :user

  after_commit on: :create do
    ChatChannel.broadcast_stream_to channel, content: {id:, user_id:}
  end
end
