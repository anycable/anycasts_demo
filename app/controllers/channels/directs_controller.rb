# frozen_string_literal: true

class Channels::DirectsController < ApplicationController
  def create
    another_user = User.find(params[:user_id])

    channel = Channel.find_or_create_direct_for(current_user, another_user)

    redirect_to channel
  end
end
