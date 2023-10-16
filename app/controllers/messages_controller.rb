class MessagesController < ApplicationController
  def create
    @channels = Channel.all.order(name: :asc)
    @current_channel = Channel.find(params[:channel_id])

    # Set current region to broadcast to others
    Current.fly_region = Rails.application.config.x.fly_region if Rails.application.config.x.fly_debug

    @message = current_channel.messages.create(message_params.merge(user: current_user))
  end

  private

  def message_params
    params.require(:message).permit(:content)
  end
end
