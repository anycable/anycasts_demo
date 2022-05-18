# frozen_string_literal: true

class Channel < ApplicationRecord
  has_many :messages, -> { order(id: :desc) }, dependent: :destroy, inverse_of: :channel

  has_many :memberships, class_name: "Channel::Membership",
    dependent: :destroy,
    inverse_of: :channel

  has_many :members, through: :memberships, source: :user

  enum kind: {
    general: "general",
    direct: "direct"
  }

  DIRECT_CHANNEL_PREFIX = "$"

  class << self
    def direct_channel_name_for(*users)
      "$#{users.map(&:id).sort.map { "u#{_1}" }.join("_")}"
    end

    def find_or_create_direct_for(*users)
      users = users.uniq
      raise ArgumentError, "At least 2 users must be provided" if users.size < 2

      name = direct_channel_name_for(*users)
      transaction do
        direct.create_or_find_by(name:).tap do |channel|
          next unless channel.saved_change_to_id?

          users.each do |user|
            channel.members << user
          end
        end
      end
    end

    def turbo_history(turbo_channel, last_id, params)
      channel = Channel.find(params[:channel_id])

      channel.messages
        .preload(:user)
        .where("id > ?", last_id)
        .reorder(id: :asc).each do |message|
        turbo_channel.transmit_append target: "messages", partial: "messages/message", locals: {message:}
      end
    end

    def turbo_broadcast_presence(params)
      channel = Channel.find(params[:channel_id])

      channel.broadcast_replace_to channel,
        partial: "channels/presence",
        locals: {current_channel: channel, users: channel.online_users},
        target: "presence"
    end
  end

  def online_users
    ::Presence.for(id).then { User.where(id: _1) }
  end
end
