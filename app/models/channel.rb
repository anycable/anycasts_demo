# frozen_string_literal: true

class Channel < ApplicationRecord
  has_many :messages, -> { order(id: :desc) }, dependent: :destroy

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
      "$#{users.map { "u#{_1.id}" }.sort.join("_")}"
    end

    def find_or_create_direct_for(*users)
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
  end
end
