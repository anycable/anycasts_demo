# frozen_string_literal: true

class Channel
  class Membership < ApplicationRecord
    belongs_to :channel
    belongs_to :user
  end
end
