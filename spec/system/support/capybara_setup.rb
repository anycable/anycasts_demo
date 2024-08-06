# frozen_string_literal: true

# Make server accessible from the outside world
Capybara.server_host = "0.0.0.0"

Capybara.app_host = "http://#{ENV.fetch("APP_HOST", `hostname`.strip&.downcase || "0.0.0.0")}"

Capybara.default_max_wait_time = 2

# Normalize whitespaces when using `has_text?` and similar matchers,
# i.e., ignore newlines, trailing spaces, etc.
# That makes tests less dependent on slightly UI changes.
Capybara.default_normalize_ws = true

# Where to store system tests artifacts (e.g. screenshots, downloaded files, etc.).
# It could be useful to be able to configure this path from the outside (e.g., on CI).
Capybara.save_path = ENV.fetch("CAPYBARA_ARTIFACTS", "./tmp/capybara")

Capybara.server_port = 3002
Capybara.server = :thruster, {debug: ENV["DEBUG"] == "1", env: {
  "ANYCABLE_BROADCAST_ADAPTER" => "http",
  "ANYCABLE_HTTP_BROADCAST_PORT" => "8090",
  "ANYCABLE_SECRET" => "test",
  "ANYCABLE_RPC_HOST" => "http://localhost:#{Capybara.server_port + 1}/_anycable"
}}

Capybara.singleton_class.prepend(Module.new do
  attr_accessor :last_used_session

  def using_session(name, &block)
    self.last_used_session = name
    super
  ensure
    self.last_used_session = nil
  end
end)
