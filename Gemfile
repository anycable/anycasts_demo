source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "~> 3.1.0"

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem "rails", "~> 7.0.0"
# PostgreSQL client library
gem "pg"

# GraphQL Ruby implementation
gem "graphql", "~> 2.0"

# Scalable WebSockets
gem "anycable-rails", "~> 1.2.0"
# Use JWT for authentication
gem "anycable-rails-jwt", "~> 0.1.0"

# The modern asset pipeline for Rails [https://github.com/rails/propshaft]
gem "propshaft"

# Use the Puma web server [https://github.com/puma/puma]
gem "puma", "~> 5.0"

# Use JavaScript with ESM import maps [https://github.com/rails/importmap-rails]
gem "importmap-rails"

# Hotwire's SPA-like page accelerator [https://turbo.hotwired.dev]
gem "turbo-rails"

# Hotwire's modest JavaScript framework [https://stimulus.hotwired.dev]
gem "stimulus-rails"

# Use Tailwind CSS [https://github.com/rails/tailwindcss-rails]
gem "tailwindcss-rails"

# Use Redis adapter to run Action Cable in production
gem "redis", "~> 4.0"

# Use Kredis to get higher-level data types in Redis [https://github.com/rails/kredis]
# gem "kredis"

# Use Active Model has_secure_password [https://guides.rubyonrails.org/active_model_basics.html#securepassword]
# gem "bcrypt", "~> 3.1.7"

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: %i[ mingw mswin x64_mingw jruby ]

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", require: false

# Use Active Storage variants [https://guides.rubyonrails.org/active_storage_overview.html#transforming-images]
# gem "image_processing", "~> 1.2"

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem "debug", platforms: %i[ mri mingw x64_mingw ]
  # Style Guide, with linter & automatic code fixer
  gem "standard", "~> 1.0", require: false
  # Static code analyzer
  gem "rubocop", require: false
  # A RuboCop extension focused on enforcing Rails best practices
  gem "rubocop-rails", require: false
  # Code style checking for RSpec files
  gem "rubocop-rspec", require: false
  # Rubocop extension for enforcing graphql-ruby best practices
  gem "rubocop-graphql", require: false
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
  # Quick automated code review of your changes
  gem "pronto"
  # Pronto runner for Rubocop, ruby code analyzer
  gem "pronto-rubocop", require: false

  # Add speed badges [https://github.com/MiniProfiler/rack-mini-profiler]
  # gem "rack-mini-profiler"

  # Speed up commands on slow machines / big apps [https://github.com/rails/spring]
  # gem "spring"
end

group :test do
  # Acceptance test framework for web applications
  gem "capybara"
  # Headless Chrome/Chromium driver for Capybara
  gem "cuprite"
end
