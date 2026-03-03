# Create an admin user in production when credentials are provided via env.
# This helps on hosts without shell access (e.g., Render free tier).

if Rails.env.production?
  Rails.application.config.after_initialize do
    rails_groups = ENV.fetch("RAILS_GROUPS", "")
    next if rails_groups.split(",").include?("assets")

    email = ENV["ADMIN_EMAIL"].to_s.strip
    password = ENV["ADMIN_PASSWORD"].to_s

    next if email.empty? || password.empty?

    begin
      unless Admin.exists?(email: email)
        Admin.create!(email: email, password: password, password_confirmation: password)
        Rails.logger.info("Bootstrap admin created for #{email}")
      end
    rescue ActiveRecord::StatementInvalid, ActiveRecord::NoDatabaseError => e
      Rails.logger.warn("Bootstrap admin skipped: #{e.class}: #{e.message}")
    end
  end
end
