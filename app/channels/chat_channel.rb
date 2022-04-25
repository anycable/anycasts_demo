# frozen_string_literal: true

class ChatChannel < Turbo::StreamsChannel
  include Turbo::Streams::TransmitAction

  def subscribed
    super
    return if subscription_rejected?

    channel_id = params[:channel_id]
    last_msg_id = params[:last_id]

    channel = Channel.find(channel_id)

    channel.messages
      .preload(:user)
      .where("id > ?", last_msg_id)
      .order(id: :asc).each do |message|
      transmit_append target: "messages", partial: "messages/message", locals: {message:}
    end
  end
end
