class ApplicationController < ActionController::Base
  attr_reader :current_channel

  helper_method :current_channel
end
