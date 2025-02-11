# frozen_string_literal: true

class OnlineChannel < ApplicationCable::Channel
  def subscribed
    stream_from "online_users"

    join_presence(id: user.id, info: {name: user.username})
  end
end
