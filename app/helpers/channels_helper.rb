# frozen_string_literal: true

module ChannelsHelper
  def channel_name_for(channel, user = nil)
    return "##{channel.name}" unless channel.direct?

    user ||= current_user

    channel.members.without(user).map do
      "@#{_1.username}"
    end.join(", ")
  end
end
