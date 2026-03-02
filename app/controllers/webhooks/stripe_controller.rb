module Webhooks
  class StripeController < ActionController::Base
    protect_from_forgery with: :null_session

    def create
      webhook_secret = ENV["STRIPE_WEBHOOK_SECRET"].to_s
      if webhook_secret.blank?
        head :bad_request
        return
      end

      payload = request.body.read
      signature = request.env["HTTP_STRIPE_SIGNATURE"].to_s

      event = ::Stripe::Webhook.construct_event(payload, signature, webhook_secret)

      case event.type
      when "checkout.session.completed"
        session = event.data.object
        order_id = session.metadata["order_id"].to_s
        order = Order.find_by(id: order_id)

        if order
          transitioned = order.mark_paid!(
            payment_provider: "stripe",
            stripe_checkout_session_id: session.id,
            stripe_payment_intent_id: session.payment_intent
          )
          OrderProcessingJob.perform_later(order.id) if transitioned
        end
      end

      head :ok
    rescue JSON::ParserError, ::Stripe::SignatureVerificationError
      head :bad_request
    end
  end
end
