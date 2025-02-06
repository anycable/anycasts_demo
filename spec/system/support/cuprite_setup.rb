# frozen_string_literal: true

require "capybara/cuprite"

# Parse URL
# NOTE: REMOTE_CHROME_HOST should be added to Webmock/VCR allowlist if you use any of those.
REMOTE_CHROME_URL = ENV["CHROME_URL"]
REMOTE_CHROME_HOST, REMOTE_CHROME_PORT =
  if REMOTE_CHROME_URL
    URI.parse(REMOTE_CHROME_URL).yield_self do |uri|
      [uri.host, uri.port]
    end
  end

# Check whether the remote chrome is running and configure the Capybara
# driver for it.
remote_chrome =
  begin
    if REMOTE_CHROME_URL.nil?
      false
    else
      Socket.tcp(REMOTE_CHROME_HOST, REMOTE_CHROME_PORT, connect_timeout: 1).close
      true
    end
  rescue Errno::ECONNREFUSED, Errno::EHOSTUNREACH, SocketError
    false
  end

remote_options = remote_chrome ? {url: REMOTE_CHROME_URL} : {}

# Name :cuprite is already registered in Capybara
# See https://github.com/rubycdp/cuprite/issues/180
Capybara.register_driver(:driver_cuprite) do |app|
  Capybara::Cuprite::Driver.new(
    app,
    window_size: [1200, 800],
    browser_options: remote_chrome ? {"no-sandbox" => nil} : {},
    # Increase Chrome startup wait time (required for stable CI builds)
    process_timeout: 10,
    # Enable debugging capabilities
    inspector: true, **remote_options
  )
end

# Configure Capybara to use :cuprite driver by default
Capybara.default_driver = Capybara.javascript_driver = :driver_cuprite

module CupriteHelpers
  # Drop #pause anywhere in a test to stop the execution.
  # Useful when you want to checkout the contents of a web page in the middle of a test
  # running in a headful mode.
  def pause
    page.driver.pause
  end

  # Drop #debug anywhere in a test to open a Chrome inspector and pause the execution
  def debug(binding = nil)
    $stdout.puts "🔎 Open Chrome inspector at http://localhost:3333"
    return binding.break if binding

    pause
  end
end

RSpec.configure do |config|
  config.include CupriteHelpers, type: :system
end
