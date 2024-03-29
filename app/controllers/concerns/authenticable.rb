# frozen_string_literal: true

module Authenticable
  extend ActiveSupport::Concern

  included do
    before_action :authenticate!
  end

  def current_user
    @current_user ||= Current.user || find_user_from_session ||
      find_user_from_cookies
  end

  private

  def authenticate!
    current_user || redirect_to(login_path)
  end

  def find_user_from_session
    return if session[:user_id].blank?

    User.find_by(id: session[:user_id])
  end

  def find_user_from_cookies
    user_id = cookies.encrypted[:user_id]
    # Only use unencrypted cookies when peforming k6 tests
    # (to simplify scripts)
    user_id = cookies[:user_id] if Rails.application.config.x.performance_testing_mode
    return if user_id.blank?

    User.find_by(id: user_id)
  end
end
