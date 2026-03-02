require Rails.root.join("app/services/payments/stripe_checkout").to_s
require Rails.root.join("app/services/payments/paypal_client").to_s

class OrderPaymentsController < ApplicationController
  before_action :authenticate_customer!
  before_action :set_order
  before_action :ensure_payable!, only: %i[show stripe paypal paypal_create paypal_capture paypal_return]

  def show
    @stripe_configured = ENV["STRIPE_SECRET_KEY"].to_s.present?
    @paypal_configured = ENV["PAYPAL_CLIENT_ID"].to_s.present? && ENV["PAYPAL_CLIENT_SECRET"].to_s.present?

    @paypal_client_id = ENV["PAYPAL_CLIENT_ID"].to_s
    @paypal_currency = ENV.fetch("PAYMENT_CURRENCY", "GBP").to_s.upcase
  end

  def stripe
    session = ::Payments::StripeCheckout.new(order: @order, base_url: request.base_url).create_session!

    @order.update!(
      payment_provider: "stripe",
      stripe_checkout_session_id: session.id,
      stripe_payment_intent_id: session.payment_intent
    )

    redirect_to session.url, allow_other_host: true
  rescue ::Payments::StripeCheckout::ConfigurationError => e
    redirect_to pay_order_path(@order), alert: e.message
  rescue Stripe::StripeError => e
    redirect_to pay_order_path(@order), alert: "Stripe error: #{e.message}"
  end

  def stripe_success
    session_id = params[:session_id].to_s
    if session_id.blank?
      redirect_to pay_order_path(@order), alert: "Missing Stripe session id."
      return
    end

    checkout = ::Payments::StripeCheckout.new(order: @order, base_url: request.base_url)
    verified = checkout.verify_paid_session!(session_id)

    if verified
      transitioned = @order.mark_paid!(
        payment_provider: "stripe",
        stripe_checkout_session_id: session_id,
        stripe_payment_intent_id: verified[:payment_intent_id]
      )
      OrderProcessingJob.perform_later(@order.id) if transitioned

      redirect_to order_path(@order), notice: "Payment successful."
    else
      redirect_to pay_order_path(@order), alert: "Payment not completed yet."
    end
  rescue ::Payments::StripeCheckout::ConfigurationError => e
    redirect_to pay_order_path(@order), alert: e.message
  rescue Stripe::StripeError => e
    redirect_to pay_order_path(@order), alert: "Stripe error: #{e.message}"
  end

  def stripe_cancel
    redirect_to pay_order_path(@order), alert: "Payment cancelled."
  end

  def paypal
    client = ::Payments::PaypalClient.from_env

    result = client.create_order(
      order: @order,
      return_url: pay_paypal_return_order_url(@order, host: request.host, port: request.optional_port, protocol: request.protocol),
      cancel_url: pay_paypal_cancel_order_url(@order, host: request.host, port: request.optional_port, protocol: request.protocol)
    )

    @order.update!(payment_provider: "paypal", paypal_order_id: result.fetch(:paypal_order_id))
    redirect_to result.fetch(:approve_url), allow_other_host: true
  rescue ::Payments::PaypalClient::ConfigurationError => e
    redirect_to pay_order_path(@order), alert: e.message
  rescue ::Payments::PaypalClient::RequestError => e
    redirect_to pay_order_path(@order), alert: "PayPal error: #{e.message}"
  end

  # PayPal Smart Buttons: Create an order and return a PayPal order id.
  def paypal_create
    client = ::Payments::PaypalClient.from_env

    result = client.create_order(order: @order)

    @order.update!(payment_provider: "paypal", paypal_order_id: result.fetch(:paypal_order_id))

    render json: { orderID: result.fetch(:paypal_order_id) }
  rescue ::Payments::PaypalClient::ConfigurationError => e
    render json: { error: e.message }, status: :unprocessable_entity
  rescue ::Payments::PaypalClient::RequestError => e
    render json: { error: "PayPal error: #{e.message}" }, status: :bad_gateway
  rescue StandardError => e
    Rails.logger.error("PayPal create failed: #{e.class}: #{e.message}")
    render json: { error: "Server error while creating PayPal order." }, status: :internal_server_error
  end

  # PayPal Smart Buttons: Capture an approved order.
  def paypal_capture
    paypal_order_id = params[:orderID].to_s
    if paypal_order_id.blank?
      render json: { error: "Missing PayPal order id." }, status: :unprocessable_entity
      return
    end

    if @order.paypal_order_id.present? && @order.paypal_order_id != paypal_order_id
      render json: { error: "PayPal order id does not match this order." }, status: :unprocessable_entity
      return
    end

    client = ::Payments::PaypalClient.from_env
    capture = client.capture_order(paypal_order_id)

    unless capture["status"].to_s == "COMPLETED"
      render json: { error: "PayPal payment not completed yet." }, status: :unprocessable_entity
      return
    end

    captured_value = capture.dig("purchase_units", 0, "payments", "captures", 0, "amount", "value")
    if captured_value.present?
      expected = @order.total_with_tax.to_d
      if captured_value.to_d != expected
        render json: { error: "PayPal amount mismatch." }, status: :unprocessable_entity
        return
      end
    end

    transitioned = @order.mark_paid!(payment_provider: "paypal", paypal_order_id: paypal_order_id)
    OrderProcessingJob.perform_later(@order.id) if transitioned

    render json: { status: "paid" }
  rescue ::Payments::PaypalClient::ConfigurationError => e
    render json: { error: e.message }, status: :unprocessable_entity
  rescue ::Payments::PaypalClient::RequestError => e
    render json: { error: "PayPal error: #{e.message}" }, status: :bad_gateway
  rescue StandardError => e
    Rails.logger.error("PayPal capture failed: #{e.class}: #{e.message}")
    render json: { error: "Server error while capturing PayPal payment." }, status: :internal_server_error
  end

  def paypal_return
    token = params[:token].to_s
    if token.blank?
      redirect_to pay_order_path(@order), alert: "Missing PayPal token."
      return
    end

    if @order.paypal_order_id.present? && @order.paypal_order_id != token
      redirect_to pay_order_path(@order), alert: "PayPal token does not match this order."
      return
    end

    client = ::Payments::PaypalClient.from_env
    capture = client.capture_order(token)

    unless capture["status"].to_s == "COMPLETED"
      redirect_to pay_order_path(@order), alert: "PayPal payment not completed yet."
      return
    end

    captured_value = capture.dig("purchase_units", 0, "payments", "captures", 0, "amount", "value")
    if captured_value.present?
      expected = @order.total_with_tax.to_d
      if captured_value.to_d != expected
        redirect_to pay_order_path(@order), alert: "PayPal amount mismatch."
        return
      end
    end

    transitioned = @order.mark_paid!(payment_provider: "paypal", paypal_order_id: token)
    OrderProcessingJob.perform_later(@order.id) if transitioned

    redirect_to order_path(@order), notice: "Payment successful."
  rescue ::Payments::PaypalClient::ConfigurationError => e
    redirect_to pay_order_path(@order), alert: e.message
  rescue ::Payments::PaypalClient::RequestError => e
    redirect_to pay_order_path(@order), alert: "PayPal error: #{e.message}"
  end

  def paypal_cancel
    redirect_to pay_order_path(@order), alert: "Payment cancelled."
  end

  private

  def set_order
    @order = current_customer.orders.find(params[:id])
  end

  def ensure_payable!
    if @order.status == "cancelled"
      respond_to do |format|
        format.html { redirect_to order_path(@order), alert: "This order is cancelled." }
        format.json { render json: { error: "This order is cancelled." }, status: :unprocessable_entity }
      end
      return
    end

    if @order.status != "pending"
      respond_to do |format|
        format.html { redirect_to order_path(@order), notice: "This order is already #{@order.status}." }
        format.json { render json: { error: "This order is already #{@order.status}." }, status: :unprocessable_entity }
      end
      return
    end
  end
end
