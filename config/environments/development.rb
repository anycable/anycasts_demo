require "active_support/core_ext/integer/time"
require 'irb'

class RemoteInputMethod < IRB::InputMethod
  # Creates a new input method object
  def initialize(queue)
    super("(remote)")
    @queue = queue
    @external_encoding = STDIN.external_encoding
  end

  def handle(msg)
    @queue << msg
  end

  def eof?
    false
  end

  def gets
    print @prompt
    @queue.pop
  end

  def encoding
    @external_encoding
  end

  # For debug message
  def inspect
    'RemoteInputMethod'
  end

  def close
  end
end

Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # Specify AnyCable WebSocket server URL to use by JS client
  config.after_initialize do
    config.action_cable.url = ActionCable.server.config.url = ENV.fetch("CABLE_URL", "ws://localhost:8080/cable") if AnyCable::Rails.enabled?
  end

  config.turbo.signed_stream_verifier_key = "s3cЯeT"

  # In the development environment your application's code is reloaded any time
  # it changes. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Do not eager load code on boot.
  config.eager_load = false

  # Show full error reports.
  config.consider_all_requests_local = true

  # Enable server timing
  config.server_timing = true

  # Enable/disable caching. By default caching is disabled.
  # Run rails dev:cache to toggle caching.
  if Rails.root.join("tmp/caching-dev.txt").exist?
    config.action_controller.perform_caching = true
    config.action_controller.enable_fragment_cache_logging = true

    config.cache_store = :memory_store
    config.public_file_server.headers = {
      "Cache-Control" => "public, max-age=#{2.days.to_i}"
    }
  else
    config.action_controller.perform_caching = false

    config.cache_store = :null_store
  end

  # Store uploaded files on the local file system (see config/storage.yml for options).
  config.active_storage.service = :local

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  # Raise exceptions for disallowed deprecations.
  config.active_support.disallowed_deprecation = :raise

  # Tell Active Support which deprecation messages to disallow.
  config.active_support.disallowed_deprecation_warnings = []

  # Raise an error on page load if there are pending migrations.
  config.active_record.migration_error = :page_load

  # Highlight code that triggered database queries in logs.
  config.active_record.verbose_query_logs = true


  # Raises error for missing translations.
  # config.i18n.raise_on_missing_translations = true

  # Annotate rendered view with file names.
  # config.action_view.annotate_rendered_view_with_filenames = true

  # Uncomment if you wish to allow Action Cable access from any origin.
  # config.action_cable.disable_request_forgery_protection = true

  console do
    require 'drb/drb'

    remote_uri = "druby://localhost:8787"
    brave_console_path = Rails.root.join("bin/brave-new-console")

    pid = fork do
      mailbox = Queue.new

      remote_input = RemoteInputMethod.new(mailbox)
      DRb.start_service(remote_uri, remote_input)
      at_exit { DRb.thread.join }

      puts "Fork #{Process.pid}"

      IRB.conf[:SCRIPT] = remote_input
      IRB.start(Rails.root.to_s)
    end

    # Process.detach(pid)

    puts "Giving control to brave-new-console from pid #{Process.pid}"

    sleep 2

    remote_console = DRbObject.new_with_uri(remote_uri)

    # exec brave_console_path.to_s
    loop do
      input = $stdin.gets
      remote_console.handle(input)
    end
  end
end
