require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module EcommerceRails
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 8.1

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w[assets tasks])

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")

    config.x.catalog_only_mode = ActiveModel::Type::Boolean.new.cast(ENV.fetch("CATALOG_ONLY_MODE", "false"))

    # Security response headers sent on every response.
    # X-Frame-Options: DENY reinforces the CSP frame-ancestors :none directive.
    # X-XSS-Protection is set to 0 — the legacy XSS auditor is retired and
    # leaving it enabled can introduce new vulnerabilities in older browsers.
    # Referrer-Policy limits referrer leakage to same-origin only on downgrade.
    # Permissions-Policy denies access to sensitive browser APIs.
    config.action_dispatch.default_headers.merge!(
      "X-Frame-Options"                  => "DENY",
      "X-Content-Type-Options"           => "nosniff",
      "X-XSS-Protection"                 => "0",
      "X-Permitted-Cross-Domain-Policies" => "none",
      "Referrer-Policy"                  => "strict-origin-when-cross-origin",
      "Permissions-Policy"               => "accelerometer=(), camera=(), " \
                                            "geolocation=(), gyroscope=(), " \
                                            "magnetometer=(), microphone=(), " \
                                            "payment=(), usb=()"
    )
  end
end
