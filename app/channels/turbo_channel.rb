# frozen_string_literal: true

class TurboChannel < Turbo::StreamsChannel
  include Turbo::Streams::TransmitAction
  include Turbo::Streams::Presence

  def history(data)
    cursor = data.fetch("cursor")
    model = params[:model].classify.constantize
    model.turbo_history(self, cursor, params)
    transmit({type: "history_ack"})
  end
end
