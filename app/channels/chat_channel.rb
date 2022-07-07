# frozen_string_literal: true

class ChatChannel < Turbo::StreamsChannel
  include Turbo::Streams::TransmitAction

  def history(payload)
    last_message_id = payload["last_message_id"]

    channel = Channel.find(params[:channel_id])

    missing_messages = channel.messages.reorder(id: :asc).where("id > ?", last_message_id)

    missing_messages.each do |message|
      transmit_append partial: "messages/message", locals: {message:}, target: "messages"
    end

    transmit({type: "history_ack"})
  end
end
