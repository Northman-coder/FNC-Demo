# For environments where predeploy hooks or shell access are unavailable (e.g., free-tier PaaS),
# apply pending migrations automatically at boot in production.

require "active_record/tasks/database_tasks"

if Rails.env.production?
  Rails.application.config.after_initialize do
    begin
      ctx = ActiveRecord::Base.connection.migration_context
      if ctx.needs_migration?
        Rails.logger.info("Auto-migrate: applying pending migrations at boot")
        ctx.migrate
      end
    rescue ActiveRecord::NoDatabaseError => e
      Rails.logger.error("Auto-migrate skipped: #{e.class}: #{e.message}")
    rescue ActiveRecord::StatementInvalid => e
      Rails.logger.warn("Auto-migrate: attempting to create database then migrate: #{e.message}")
      begin
        ActiveRecord::Tasks::DatabaseTasks.create_current
        ActiveRecord::Base.connection.migration_context.migrate
      rescue => inner
        Rails.logger.error("Auto-migrate failed: #{inner.class}: #{inner.message}")
      end
    end
  end
end
