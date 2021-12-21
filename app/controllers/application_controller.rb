class ApplicationController < ActionController::Base
  attr_reader :current_channel

  helper_method :current_channel
  helper_method :current_user

  def current_user
    @current_user ||= (session[:user] ||= "user-#{rand(20)}")
  end
end
