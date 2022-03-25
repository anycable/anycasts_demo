# frozen_string_literal: true

class User < ApplicationRecord
  has_secure_password

  validates :username, presence: true, length: {maximum: 120}

  has_many :channel_memberships, class_name: "Channel::Membership",
    inverse_of: :user,
    dependent: :destroy
  has_many :direct_channels, -> { direct }, through: :channel_memberships,
    source: :channel
end
