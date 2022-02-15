class ApplicationController < ActionController::Base
  include Authenticable

  attr_reader :current_channel

  helper_method :current_channel
  helper_method :current_user
end
