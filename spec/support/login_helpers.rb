# frozen_string_literal: true

module LoginHelpers
  module System
    def login(user)
      encrypted_user_id =
        ActionDispatch::Request.new(Rails.application.env_config.deep_dup).cookie_jar.then do |jar|
          jar.encrypted[:user_id] = user.id.to_s
          jar[:user_id]
        end.then(&CGI.method(:escape))

      page.driver.set_cookie(
        :user_id,
        encrypted_user_id
      )
    end

    def logout
      page.driver.clear_cookies
    end
  end

  module Controller
    def login(user)
      @request.session.merge!(user_id: user.id)
    end
  end
end

RSpec.configure do |config|
  config.include LoginHelpers::System, type: :system
  config.after(:each, type: :system) { logout }

  config.include LoginHelpers::Controller, type: :controller
end
