# frozen_string_literal: true

module Turbo
  module Streams
    module Presence
      extend ActiveSupport::Concern

      included do
        after_subscribe :add_presence, if: :presence_enabled?
        after_unsubscribe :remove_presence, if: :presence_enabled?
      end

      def presence_enabled?
        params[:presence]
      end

      def broadcast_presence
        model = params[:model].classify.constantize
        model.turbo_broadcast_presence(params)
      end

      def add_presence
        ::Presence.add(presence_identifier, connection.presence_user_id)
        maybe_expire
        broadcast_presence
      end

      def presence_keepalive
        ::Presence.touch(presence_identifier, connection.presence_user_id)
      end

      def remove_presence
        ::Presence.remove(presence_identifier, connection.presence_user_id)
        broadcast_presence
      end

      def presence_identifier
        params[:presence]
      end

      private

      def maybe_expire
        return false if rand > 0.3

        ::Presence.expire(presence_identifier)
      end
    end
  end
end
