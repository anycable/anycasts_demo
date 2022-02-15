# frozen_string_literal: true

class APIController < ActionController::API
  include ActionDispatch::Session
  include Authenticable

  def authenticate!
    current_user || head(:unauthorized)
  end
end
