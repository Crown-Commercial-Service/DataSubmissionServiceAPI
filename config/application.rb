require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module DataSubmissionServiceApi
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.2
    config.autoloader = :zeitwerk

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.

    # Use UUIDs as primary keys by default
    config.generators do |g|
      g.orm :active_record, primary_key_type: :uuid
    end

    # Use Sidekiq for background jobs
    config.active_job.queue_adapter = :sidekiq

    console do
      require './lib/console_helpers'
      if defined?(Pry)
        TOPLEVEL_BINDING.eval('self').extend ConsoleHelpers
      else
        Rails::ConsoleMethods.include ConsoleHelpers
      end
    end
  end
end
