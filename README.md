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
