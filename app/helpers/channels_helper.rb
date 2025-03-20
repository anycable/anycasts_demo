# frozen_string_literal: true

module ChannelsHelper
  def link_to_channel(channel, user = nil)
    return link_to("##{channel.name}", channel) unless channel.direct?

    user ||= current_user

    others = channel.members.without(user).to_a

    link_to channel do
      others.map do |u|
        content_tag(:span, class: "flex flex-row items-baseline") do
          content_tag(:span, "@#{u.username}") +
            content_tag(:i, "online", class: "ml-1 online-indicator font-normal text-sm not-italic text-teal-400", data: {online_target: :user, id: u.id})
        end
      end.join(", ").html_safe # rubocop:disable Rails/OutputSafety
    end
  end
end
