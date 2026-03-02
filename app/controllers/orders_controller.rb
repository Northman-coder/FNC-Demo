class OrdersController < ApplicationController
  before_action :authenticate_customer!
  before_action :ensure_catalog_open!, only: [:create, :cancel]

  def index
    @orders = current_customer.orders.order(created_at: :desc)
  end

  def show
    @order = current_customer.orders.find(params[:id])
  end

  def create
    basket = Basket.new(session)
    items = basket.items

    if items.empty?
      basket.clear
      redirect_to basket_path, alert: "Your basket is empty."
      return
    end

    order = current_customer.orders.build(status: "pending", total_price: 0)
    placed = false

    Order.transaction do
      order.save!

      items.each do |item|
        product = item[:product]
        quantity = item[:quantity].to_i
        next if quantity <= 0

        order.order_items.create!(
          product: product,
          quantity: quantity,
          unit_price: product.price || 0
        )
      end

      raise ActiveRecord::Rollback if order.order_items.none?

      # gross_total is the VAT-inclusive total (product prices already include VAT)
      gross_total = order.order_items.sum(Arel.sql("quantity * unit_price"))

      tax_setting = TaxSetting.current
      tax_region = tax_setting.region_for_country(current_customer.country)
      tax_percent = tax_setting.percent_for_region(tax_region)
      tax_rate = tax_percent.to_d / 100
      # Extract VAT from the inclusive price: VAT = gross × rate / (1 + rate)
      tax_amount = (gross_total.to_d * tax_rate / (1 + tax_rate)).round(2)

      order.update!(
        total_price: gross_total,
        tax_region: tax_region,
        tax_percent: tax_percent,
        tax_amount: tax_amount
      )
      placed = true
    end

    if placed
      basket.clear
      redirect_to pay_order_path(order), notice: "Order created — please complete payment to confirm it."
    else
      redirect_to basket_path, alert: "Could not place your order. Please try again."
    end
  end

  def cancel
    @order = current_customer.orders.find(params[:id])

    unless @order.cancellable_by_customer?
      redirect_to order_path(@order), alert: "This order can no longer be cancelled."
      return
    end

    @order.update!(status: "cancelled")
    redirect_to order_path(@order), notice: "Order cancelled."
  end
end
