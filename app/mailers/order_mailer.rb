class OrderMailer < ApplicationMailer
  def order_confirmation(order)
    @order = order
    @customer = order.customer
    @items = order.order_items.includes(:product)
    mail(
      to: @customer.email,
      subject: "Order Confirmed – #{@order.order_number}"
    )
  end

  def order_status_update(order)
    @order = order
    @customer = order.customer
    @items = order.order_items.includes(:product)
    mail(
      to: @customer.email,
      subject: "Your order #{@order.order_number} has been #{@order.status}"
    )
  end
end
