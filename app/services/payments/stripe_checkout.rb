module Payments
  class StripeCheckout
    class ConfigurationError < StandardError; end

    def initialize(order:, base_url:, currency: ENV.fetch("PAYMENT_CURRENCY", "GBP"))
      @order = order
      @base_url = base_url
      @currency = currency.to_s.downcase
    end

    def create_session!
      ensure_configured!

      Stripe::Checkout::Session.create(
        mode: "payment",
        client_reference_id: @order.id,
        metadata: {
          order_id: @order.id,
          customer_id: @order.customer_id
        },
        customer_email: @order.customer.email,
        line_items: line_items,
        success_url: success_url,
        cancel_url: cancel_url
      )
    end

    # Returns a hash when paid, or false/nil when not paid.
    def verify_paid_session!(session_id)
      ensure_configured!

      session = Stripe::Checkout::Session.retrieve(session_id)

      return false if session.payment_status != "paid"
      return false unless session.metadata["order_id"].to_s == @order.id.to_s

      expected_total = order_total_cents
      return false if session.amount_total.to_i != expected_total

      {
        payment_intent_id: session.payment_intent
      }
    end

    private

    def ensure_configured!
      secret_key = ENV["STRIPE_SECRET_KEY"].to_s
      raise ConfigurationError, "Stripe is not configured (missing STRIPE_SECRET_KEY)." if secret_key.blank?

      Stripe.api_key = secret_key
    end

    def order_total_cents
      (@order.total_with_tax.to_d * 100).round(0).to_i
    end

    def line_items
      @order.order_items.includes(:product).map do |item|
        unit_amount = (item.unit_price.to_d * 100).round(0).to_i
        raise ArgumentError, "Invalid item price" if unit_amount <= 0

        {
          quantity: item.quantity,
          price_data: {
            currency: @currency,
            unit_amount: unit_amount,
            product_data: {
              name: item.product.name.to_s
            }
          }
        }
      end
    end

    def success_url
      "#{@base_url}/orders/#{@order.id}/pay/stripe/success?session_id={CHECKOUT_SESSION_ID}"
    end

    def cancel_url
      "#{@base_url}/orders/#{@order.id}/pay/stripe/cancel"
    end
  end
end
