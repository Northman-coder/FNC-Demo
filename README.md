# README

This README would normally document whatever steps are necessary to get the
application up and running.

Things you may want to cover:

* Ruby version

* System dependencies

* Configuration

* Database creation

* Database initialization

* How to run the test suite

* Services (job queues, cache servers, search engines, etc.)

* Deployment instructions

* ...

## Payments (Stripe + PayPal)

This app supports two payment providers for customer orders:

- Stripe (hosted Stripe Checkout)
- PayPal (redirect + server-side capture)

### Environment variables

Set these (for local dev you can use a `.env` file via `dotenv-rails`):

- `STRIPE_SECRET_KEY` (required for Stripe Checkout)
- `STRIPE_WEBHOOK_SECRET` (required for Stripe webhook verification)
- `PAYPAL_CLIENT_ID` (required for PayPal)
- `PAYPAL_CLIENT_SECRET` (required for PayPal)
- `PAYPAL_ENV` (`sandbox` default, set to `live` in production)
- `PAYMENT_CURRENCY` (optional; defaults to `gbp` for Stripe and `GBP` for PayPal)

### Webhooks

- Stripe webhook endpoint: `POST /webhooks/stripe`
	- Suggested event: `checkout.session.completed`
# FNC-Demo
# FNC-Demo

## Deploy to Render

This repository is already configured for Render via `render.yaml`.

### 1) Push to GitHub

Make sure the latest code is pushed to your GitHub repo/branch.

### 2) Create services from Blueprint

In Render:

1. Go to **New +** → **Blueprint**.
2. Connect your GitHub repo.
3. Select this repository so Render reads `render.yaml`.
4. Create all resources.

This creates:

- `ecommerce-db` (PostgreSQL)
- `ecommerce-redis` (Key Value / Redis)
- `ecommerce-web` (Rails web service)
- `ecommerce-worker` (Sidekiq worker)

### 3) Set required environment variables

Set these in **both** `ecommerce-web` and `ecommerce-worker` unless noted.

Required:

- `RAILS_MASTER_KEY`
- `RAILS_HOSTS` (for example: `your-app.onrender.com`)

Payments (if used):

- `STRIPE_SECRET_KEY`
- `STRIPE_WEBHOOK_SECRET`
- `PAYPAL_CLIENT_ID`
- `PAYPAL_CLIENT_SECRET`
- `PAYPAL_ENV` (`sandbox` or `live`)
- `PAYMENT_CURRENCY` (optional)

Email (optional, for mail delivery):

- `SMTP_ADDRESS`
- `SMTP_PORT`
- `SMTP_USERNAME`
- `SMTP_PASSWORD`
- `SMTP_DOMAIN`

Notes:

- `DATABASE_URL` and `REDIS_URL` are wired automatically from `render.yaml`.
- The web service health check is `GET /up`.

### 4) Deploy

Trigger deploy (or wait for auto-deploy). Render will:

- run `bash bin/render-build.sh`
- run `bash bin/render-preflight.sh && bundle exec rails db:prepare` before web deploy
- run `bundle exec rails db:prepare` at service startup, then start Puma/Sidekiq

If you are on Render free tier and don't have Shell access, this startup `db:prepare`
step ensures schema setup still happens on deploy/restart.

You can run the same check manually at any time:

```bash
bash bin/render-preflight.sh
```

### 5) Create first admin user (one-time)

Open a Render shell on `ecommerce-web` and run:

```bash
bundle exec rails console
Admin.create!(email: "admin@example.com", password: "change-me-now", password_confirmation: "change-me-now")
```

Then sign in at `/admin`.

### 6) Configure Stripe webhook (if Stripe enabled)

In Stripe Dashboard, point webhook endpoint to:

- `https://<your-render-domain>/webhooks/stripe`

Add `checkout.session.completed` and use the signing secret in `STRIPE_WEBHOOK_SECRET`.
