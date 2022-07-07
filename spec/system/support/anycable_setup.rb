# frozen_string_literal: true

# Run AnyCable RPC server
RSpec.configure do |config|
  # Skip assets precompilcation if we exclude system specs.
  next if config.filter.opposite.rules[:type] == "system" || config.exclude_pattern.match?(%r{spec/system})

  require "anycable/cli"

  cli = AnyCable::CLI.new(embedded: true)
  cli.run

  config.after(:suite) do
    cli&.shutdown
  end
end
