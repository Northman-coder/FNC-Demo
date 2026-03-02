class Order < ApplicationRecord
  STATUSES = %w[pending paid shipped delivered cancelled].freeze

  CUSTOMER_CANCELLABLE_STATUSES = %w[pending paid].freeze

  belongs_to :customer
  has_many :order_items, dependent: :destroy
  has_many :products, through: :order_items

  validates :status, inclusion: { in: STATUSES }
  validates :total_price, numericality: { greater_than_or_equal_to: 0 }

  # Ex-VAT amount (VAT extracted from the inclusive price)
  def subtotal_price
    (total_price.to_d - tax_amount.to_d).round(2)
  end

  # Total is already VAT-inclusive — product prices include VAT
  def total_with_tax
    total_price
  end

  def cancellable_by_customer?
    CUSTOMER_CANCELLABLE_STATUSES.include?(status)
  end

  # Human-readable order reference: YYYYMMDD-XXXX  e.g. 20260228-0004
  def order_number
    "#{created_at.strftime('%Y%m%d')}-#{id.to_s.rjust(4, '0')}"
  end

  def paid?
    status == "paid"
  end

  # Transitions the order to paid exactly once.
  # Returns true if the order was transitioned, false if it was already paid.
  def mark_paid!(payment_provider:, stripe_checkout_session_id: nil, stripe_payment_intent_id: nil, paypal_order_id: nil)
    with_lock do
      return false if paid?
      return false unless status == "pending"

      update!(
        status: "paid",
        paid_at: Time.current,
        payment_provider: payment_provider,
        stripe_checkout_session_id: stripe_checkout_session_id,
        stripe_payment_intent_id: stripe_payment_intent_id,
        paypal_order_id: paypal_order_id
      )

      true
    end
  end
end
