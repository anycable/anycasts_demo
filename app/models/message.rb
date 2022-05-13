class Message < ApplicationRecord
  belongs_to :channel, touch: true
  belongs_to :user

  after_commit on: :create do
    broadcast_append_to channel, partial: "messages/message", locals: {message: self}, target: "messages"
  end

  def self.turbo_history(turbo_channel, last_id, params)
    channel = Channel.find(params[:channel_id])

    channel.messages
      .preload(:user)
      .where("id > ?", last_id)
      .reorder(id: :asc).each do |message|
      turbo_channel.transmit_append target: "messages", partial: "messages/message", locals: {message:}
    end
  end
end
