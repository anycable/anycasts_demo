# frozen_string_literal: true

module ApplicationHelper
  # Override stream from to use an enhanced element
  def turbo_history_stream_from(*streamables, **attributes)
    attributes[:channel] = attributes[:channel]&.to_s || "TurboChannel"
    attributes[:"signed-stream-name"] = Turbo::StreamsChannel.signed_stream_name(streamables)
    attributes[:params] = attributes[:params]&.to_json
    attributes[:"cursor-selector"] = attributes.delete(:cursor)

    tag.turbo_cable_stream_source_history(**attributes)
  end
end
