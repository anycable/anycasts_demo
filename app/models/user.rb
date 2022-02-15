# frozen_string_literal: true

class User < ApplicationRecord
  has_secure_password

  validates :username, presence: true, length: {maximum: 120}
end
