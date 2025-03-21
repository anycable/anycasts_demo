source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "~> 3.3.0"

# Bundle edge Rails instead:
# gem "rails", github: "rails/rails", branch: "main"
gem "rails", "~> 8.0"
# SQLlite3 is good enough for us
gem "sqlite3", "~> 2.0"

# GraphQL Ruby implementation
gem "graphql", "~> 2.0"

# Scalable WebSockets
gem "anycable-rails", "~> 1.6"

# The modern asset pipeline for Rails [https://github.com/rails/propshaft]
gem "propshaft"

# Use the Puma web server [https://github.com/puma/puma]
gem "puma", "~> 6.0"

# Use JavaScript with ESM import maps [https://github.com/rails/importmap-rails]
gem "importmap-rails"

# Hotwire's SPA-like page accelerator [https://turbo.hotwired.dev]
gem "turbo-rails"

# Hotwire's modest JavaScript framework [https://stimulus.hotwired.dev]
gem "stimulus-rails"

# Use Tailwind CSS [https://github.com/rails/tailwindcss-rails]
gem "tailwindcss-rails", "~> 3.0"

# Use Redis adapter to run Action Cable in production
gem "redis", "~> 5.0"

# Or use NATS
gem "nats-pure"

# Use Kredis to get higher-level data types in Redis [https://github.com/rails/kredis]
# gem "kredis"

# Use Active Model has_secure_password [https://guides.rubyonrails.org/active_model_basics.html#securepassword]
gem "bcrypt", "~> 3.1.7"

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: %i[ mingw mswin x64_mingw jruby ]

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", require: false

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem "debug", platforms: %i[ mri mingw x64_mingw ]
  # RSpec for Rails 5+
  gem "rspec-rails"
  # Factory Bot ♥ Rails
  gem "factory_bot_rails"
  # A library for generating fake data
  gem "faker"
end

group :development do
  # Use console on exceptions pages [https://github.com/rails/web-console]
  gem "web-console"
  # Process manager for development
  gem "overmind"

  eval_gemfile "gemfiles/rubocop.gemfile"
end

group :test do
  # Acceptance test framework for web applications
  gem "capybara"
  # Headless Chrome/Chromium driver for Capybara
  gem "cuprite"
  # Use Thruster with AnyCable in browser tests
  gem "anycable-thruster"
  # Use Thruster as Capybara server
  gem "capybara-thruster"
  # Tests profiling utils
  gem "test-prof"
end
