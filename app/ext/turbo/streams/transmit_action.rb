# frozen_string_literal: true

module Turbo
  module Streams
    module TransmitAction
      include Turbo::Streams::ActionHelper

      def transmit_remove(**opts)
        transmit_action(action: :remove, **opts)
      end

      def transmit_replace(**opts)
        transmit_action(action: :replace, **opts)
      end

      def transmit_update(**opts)
        transmit_action(action: :update, **opts)
      end

      def transmit_before(**opts)
        transmit_action(action: :before, **opts)
      end

      def transmit_after(**opts)
        transmit_action(action: :after, **opts)
      end

      def transmit_append(**opts)
        transmit_action(action: :append, **opts)
      end

      def transmit_prepend(**opts)
        transmit_action(action: :prepend, **opts)
      end

      def transmit_action(action:, target: nil, targets: nil, **rendering)
        payload = turbo_stream_action_tag(
          action, target: target, targets: targets,
          template: rendering.delete(:content) || (rendering.any? ? render_format(:html, **rendering) : nil)
        )

        transmit payload
      end

      private

      def render_format(format, **rendering)
        ApplicationController.render(formats: [format], **rendering)
      end
    end
  end
end
