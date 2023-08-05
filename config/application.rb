require_relative "boot"

require "rails"
# Pick the frameworks you want:
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
require "active_storage/engine"
require "action_controller/railtie"
require "action_mailer/railtie"
require "action_mailbox/engine"
require "action_text/engine"
require "action_view/railtie"
require "action_cable/engine"
# require "sprockets/railtie"
# require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module TogodxServer
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 6.1

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")

    # Only loads a smaller set of middleware suitable for API only apps.
    # Middleware like session, flash, cookies can be added back manually.
    # Skip views, helpers and assets when generating a new resource.
    config.api_only = true

    ATTRIBUTES_YAML = Rails.root / 'config' / 'attributes.yml'
    DATASETS_YAML = Rails.root / 'config' / 'datasets.yml'

    def self.load_config(file)
      file.exist? ? YAML.load_file(file) : {}
    end

    togodx = {
      attributes: load_config(ATTRIBUTES_YAML),
      datasets: load_config(DATASETS_YAML)
    }.with_indifferent_access

    class << togodx
      def validate
        undefined = self[:attributes].map { |_, v| v[:dataset] }.uniq - self[:datasets].map { |_, v| v[:key] }.uniq

        raise RuntimeError, "Dataset definition not found: #{undefined.join(', ')} in #{DATASETS_YAML}" if undefined.present?

        self
      end

      def dataset_pairs
        self[:attributes].map { |_, v| v[:dataset] }.uniq.sort.combination(2)
      end
    end

    config.togodx = togodx.validate
  end
end
