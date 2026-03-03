#!/usr/bin/env bash
set -euo pipefail

# Fail-fast checks for Render production deploys.

required_vars=(
  RAILS_MASTER_KEY
  RAILS_HOSTS
  DATABASE_URL
  REDIS_URL
)

missing=()
for var in "${required_vars[@]}"; do
  if [[ -z "${!var:-}" ]]; then
    missing+=("$var")
  fi
done

if (( ${#missing[@]} > 0 )); then
  echo "❌ Missing required environment variables:" >&2
  for var in "${missing[@]}"; do
    echo "   - $var" >&2
  done
  exit 1
fi

echo "✅ Core env vars present"

# Payment provider sanity checks (warn-only)
stripe_vars=(STRIPE_SECRET_KEY STRIPE_WEBHOOK_SECRET)
paypal_vars=(PAYPAL_CLIENT_ID PAYPAL_CLIENT_SECRET)

missing_stripe=()
for var in "${stripe_vars[@]}"; do
  [[ -z "${!var:-}" ]] && missing_stripe+=("$var")
done

missing_paypal=()
for var in "${paypal_vars[@]}"; do
  [[ -z "${!var:-}" ]] && missing_paypal+=("$var")
done

if (( ${#missing_stripe[@]} > 0 )) && (( ${#missing_stripe[@]} < ${#stripe_vars[@]} )); then
  echo "⚠️  Stripe is partially configured. Missing: ${missing_stripe[*]}" >&2
fi

if (( ${#missing_paypal[@]} > 0 )) && (( ${#missing_paypal[@]} < ${#paypal_vars[@]} )); then
  echo "⚠️  PayPal is partially configured. Missing: ${missing_paypal[*]}" >&2
fi

echo "✅ Render preflight complete"
