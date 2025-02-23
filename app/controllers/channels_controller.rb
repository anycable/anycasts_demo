class ChannelsController < ApplicationController
  before_action :set_channels
  before_action :set_channel, only: %i[show]

  # GET /channels
  def index
    redirect_to @channels.first
  end

  # GET /channels/1
  def show
    render action: :index
  end

  private

  def set_channels
    @channels = Channel.general.order(name: :asc)
  end

  def set_channel
    @current_channel = Channel.find(params[:id])
  end
end
