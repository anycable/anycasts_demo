# frozen_string_literal: true

module Authenticable
  extend ActiveSupport::Concern
  include ActionDispatch::Session

  def current_user
    @current_user ||= (session[:user] ||= "user-#{rand(20)}")
  end
end
