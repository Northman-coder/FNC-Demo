# Ensure production has baseline catalog data even when shells/predeploy hooks are unavailable (e.g., Render free tier).
# Idempotent: runs seeds only when categories or products are empty.

if Rails.env.production?
  Rails.application.config.after_initialize do
    rails_groups = ENV.fetch("RAILS_GROUPS", "")
    next if rails_groups.split(",").include?("assets")

    begin
      needs_seed = Category.count.zero? || Product.count.zero?
    rescue ActiveRecord::StatementInvalid => e
      Rails.logger.warn("Seed bootstrap skipped: #{e.class}: #{e.message}")
      next
    end

    if needs_seed
      Rails.logger.info("Bootstrapping catalog data via db/seeds.rb")
      load Rails.root.join("db/seeds.rb")
    end
  end
end
