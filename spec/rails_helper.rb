# frozen_string_literal: true

require "spec_helper"
ENV["RAILS_ENV"] = "test"

require_relative "../config/environment"
abort("The Rails environment is running in production mode!") if Rails.env.production?

require "rspec/rails"

Dir[Rails.root.join("spec", "support", "**", "*.rb")].sort.each { |f| require f }

begin
  ActiveRecord::Migration.maintain_test_schema!
rescue ActiveRecord::PendingMigrationError => e
  puts e.to_s.strip
  exit 1
end

RSpec.configure do |config|
  config.infer_spec_type_from_file_location!
  config.filter_rails_from_backtrace!
  config.use_transactional_fixtures = true

  config.define_derived_metadata(file_path: %r{/spec/}) do |metadata|
    # do not overwrite type if it's already set
    next if metadata.key?(:type)

    match = metadata[:location].match(%r{/spec/([^/]+)/})
    metadata[:type] = match[1].singularize.to_sym
  end
end
