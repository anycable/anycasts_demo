# frozen_string_literal: true

module ApplicationHelper
  # Override stream from to use an enhanced element
  def turbo_stream_from(*streamables, **attributes)
    attributes[:channel] = attributes[:channel]&.to_s || "Turbo::StreamsChannel"
    attributes[:"signed-stream-name"] = Turbo::StreamsChannel.signed_stream_name(streamables)
    attributes[:params] = attributes[:params]&.to_json

    tag.turbo_cable_stream_source_ext(**attributes)
  end
end
