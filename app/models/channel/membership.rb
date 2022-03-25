# frozen_string_literal: true

class Channel
  class Membership < ApplicationRecord
    belongs_to :channel
    belongs_to :user

    after_commit do
      Current.set(user:) do
        broadcast_prepend_to(
          user,
          target: :directs,
          partial: "channels/channel",
          locals: {channel:}
        )
      end
    end
  end
end
