class PriceAlertsController < ApplicationController
  def create
    product = Product.find(price_alert_params.fetch(:product_id))
    alert = product.price_alerts.where(email: price_alert_params[:email], phone: price_alert_params[:phone]).first_or_initialize
    alert.assign_attributes(price_alert_params.except(:product_id))
    alert.confirmed_at ||= Time.current

    if alert.save
      respond_to do |format|
        format.html { redirect_back fallback_location: product_path(product), notice: "We'll notify you when the price drops." }
        format.json { render json: { status: "ok", token: alert.token }, status: :created }
      end
    else
      respond_to do |format|
        format.html { redirect_back fallback_location: product_path(product), alert: alert.errors.full_messages.to_sentence }
        format.json { render json: { errors: alert.errors.full_messages }, status: :unprocessable_entity }
      end
    end
  end

  def confirm
    alert = PriceAlert.find_by!(token: params[:token])
    alert.confirm!
    redirect_to product_path(alert.product), notice: "Price alert confirmed."
  end

  private

  def price_alert_params
    params.expect(price_alert: [:product_id, :email, :phone, :target_price])
  end
end
