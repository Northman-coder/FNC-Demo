# frozen_string_literal: true

class Rack::Attack
  # ── Helpers ──────────────────────────────────────────────────────────────────

  # Normalise the remote IP, respecting X-Forwarded-For when behind a proxy.
  # In production Rails sets request.ip correctly; fall back to REMOTE_ADDR.
  throttle_key = ->(req) { req.ip }

  # ── Authentication endpoints ──────────────────────────────────────────────────

  # Customer sign-in: max 5 attempts per IP per minute
  throttle("logins/ip/customers", limit: 5, period: 1.minute) do |req|
    req.ip if req.post? && req.path == "/customers/sign_in"
  end

  # Admin sign-in: stricter — max 3 attempts per IP per 2 minutes
  throttle("logins/ip/admins", limit: 3, period: 2.minutes) do |req|
    req.ip if req.post? && req.path == "/admins/sign_in"
  end

  # Also throttle by email to prevent distributed brute-force across many IPs
  throttle("logins/email/customers", limit: 5, period: 20.minutes) do |req|
    if req.post? && req.path == "/customers/sign_in"
      req.params.dig("customer", "email").to_s.downcase.strip.presence
    end
  end

  throttle("logins/email/admins", limit: 3, period: 20.minutes) do |req|
    if req.post? && req.path == "/admins/sign_in"
      req.params.dig("admin", "email").to_s.downcase.strip.presence
    end
  end

  # ── Registration ──────────────────────────────────────────────────────────────

  # Customer sign-up: max 3 new accounts per IP per 10 minutes
  throttle("signups/ip", limit: 3, period: 10.minutes) do |req|
    req.ip if req.post? && req.path == "/customers"
  end

  # ── Password reset ────────────────────────────────────────────────────────────

  throttle("passwords/ip", limit: 5, period: 10.minutes) do |req|
    req.ip if req.post? && req.path.start_with?("/customers/password")
  end

  # ── Contact form ──────────────────────────────────────────────────────────────

  throttle("contact/ip", limit: 3, period: 5.minutes) do |req|
    req.ip if req.post? && req.path == "/contact_messages"
  end

  # ── Search ────────────────────────────────────────────────────────────────────

  throttle("search/ip", limit: 30, period: 1.minute) do |req|
    req.ip if req.get? && req.path == "/products" && req.params["query"].present?
  end

  # ── General burst protection (all requests) ───────────────────────────────────

  # Block IPs hammering more than 300 requests per minute
  throttle("req/ip", limit: 300, period: 1.minute, &throttle_key)

  # ── Response for throttled requests ──────────────────────────────────────────

  self.throttled_responder = lambda do |env|
    retry_after = (env["rack.attack.match_data"] || {})[:period]
    [
      429,
      {
        "Content-Type" => "text/plain",
        "Retry-After" => retry_after.to_s
      },
      [ "Too many requests. Please try again later." ]
    ]
  end
end

# Mount Rack::Attack as middleware
Rails.application.config.middleware.use Rack::Attack
