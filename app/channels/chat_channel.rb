# frozen_string_literal: true

class ChatChannel < Turbo::StreamsChannel
  include Turbo::Streams::TransmitAction

  def subscribed
    if stream_name = verified_stream_name_from_params # rubocop:disable Lint/AssignmentInCondition
      stream_from(stream_name) do |raw_payload|
        payload = JSON.parse(raw_payload)
        message = Message.find(payload["id"])

        Current.set(user:) do
          transmit_append partial: "messages/message", locals: {message:}, target: "messages"
        end
      end
    else
      reject
    end
  end
end
