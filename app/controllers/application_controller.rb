# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include Authenticable

  attr_reader :current_channel

  helper_method :current_channel
  helper_method :current_user

  around_action :set_locale

  private

  def set_locale(&action)
    locale = current_user&.username&.match?(/vova/i) ? "ru" : I18n.default_locale

    I18n.with_locale(locale, &action)
  end
end
