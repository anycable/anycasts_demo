# frozen_string_literal: true

class User < ApplicationRecord
  has_secure_password

  validates :username, presence: true, length: {maximum: 120}

  has_many :channel_memberships, class_name: "Channel::Membership",
    inverse_of: :user,
    dependent: :destroy
  has_many :direct_channels, -> { direct.order(created_at: :desc) }, through: :channel_memberships,
    source: :channel

  COLORS = %w[rose purple green yellow pink indigo].freeze

  def color = COLORS[id % COLORS.size]
end
