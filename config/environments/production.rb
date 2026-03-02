require "active_support/core_ext/integer/time"

Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # Code is not reloaded between requests.
  config.enable_reloading = false

  # Eager load code on boot for better performance and memory savings (ignored by Rake tasks).
  config.eager_load = true

  # Full error reports are disabled.
  config.consider_all_requests_local = false

  # Turn on fragment caching in view templates.
  config.action_controller.perform_caching = true

  # Serve precompiled assets directly from the app.
  config.public_file_server.enabled = true

  # Cache assets for far-future expiry since they are all digest stamped.
  config.public_file_server.headers = { "cache-control" => "public, max-age=#{1.year.to_i}" }

  # Enable serving of images, stylesheets, and JavaScripts from an asset server.
  # config.asset_host = "http://assets.example.com"

  # Store uploaded files on the local file system (see config/storage.yml for options).
  config.active_storage.service = :local

  # Assume all access to the app is happening through a SSL-terminating reverse proxy.
  config.assume_ssl = true

  # Force all access to the app over SSL, use Strict-Transport-Security, and use secure cookies.
  config.force_ssl = true

  # Skip http-to-https redirect for the health check endpoint.
  config.ssl_options = { hsts: { expires: 1.year, subdomains: true }, redirect: { exclude: ->(request) { request.path == "/up" } } }

  # Log to STDOUT with the current request id as a default log tag.
  config.log_tags = [ :request_id ]
  config.logger   = ActiveSupport::TaggedLogging.logger(STDOUT)

  # Change to "debug" to log everything (including potentially personally-identifiable information!).
  config.log_level = ENV.fetch("RAILS_LOG_LEVEL", "info")

  # Prevent health checks from clogging up the logs.
  config.silence_healthcheck_path = "/up"

  # Don't log any deprecations.
  config.active_support.report_deprecations = false

  # Replace the default in-process memory cache store with a durable alternative.
  config.cache_store = :solid_cache_store

  # Replace the default in-process and non-durable queuing backend for Active Job.
  config.active_job.queue_adapter = :sidekiq

  config.action_mailer.raise_delivery_errors = true
  config.action_mailer.perform_deliveries = true

  # Reuse the same domain set in RAILS_HOSTS for email links.
  app_host = ENV.fetch("RAILS_HOSTS", "example.com").split(",").first.strip
  config.action_mailer.default_url_options = { host: app_host, protocol: "https" }

  # SMTP — set these environment variables on your server / in Kamal secrets:
  #   SMTP_ADDRESS   e.g. smtp.sendgrid.net  or  smtp.mailgun.org
  #   SMTP_PORT      587 (STARTTLS) or 465 (SSL)
  #   SMTP_USERNAME  your SMTP login / API key username
  #   SMTP_PASSWORD  your SMTP password / API key
  #   SMTP_DOMAIN    your sending domain  e.g. mystore.com
  if ENV["SMTP_ADDRESS"].present?
    config.action_mailer.delivery_method = :smtp
    config.action_mailer.smtp_settings = {
      address:              ENV["SMTP_ADDRESS"],
      port:                 ENV.fetch("SMTP_PORT", "587").to_i,
      domain:               ENV.fetch("SMTP_DOMAIN", app_host),
      user_name:            ENV["SMTP_USERNAME"],
      password:             ENV["SMTP_PASSWORD"],
      authentication:       :plain,
      enable_starttls_auto: true
    }
  end

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation cannot be found).
  config.i18n.fallbacks = true

  # Do not dump schema after migrations.
  config.active_record.dump_schema_after_migration = false

  # Only use :id for inspections in production.
  config.active_record.attributes_for_inspect = [ :id ]

  # Enable DNS rebinding protection. Set RAILS_HOSTS env var to your domain(s),
  # comma-separated (e.g. "mystore.com,www.mystore.com").
  allowed_hosts = ENV.fetch("RAILS_HOSTS", "").split(",").map(&:strip).reject(&:empty?)
  config.hosts = allowed_hosts unless allowed_hosts.empty?
  config.host_authorization = { exclude: ->(request) { request.path == "/up" } }
end
