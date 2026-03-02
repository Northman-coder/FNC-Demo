# frozen_string_literal: true

class OrderProcessingJob < ApplicationJob
  queue_as :critical

  def perform(order_id)
    order = Order.includes(order_items: :product).find(order_id)

    OrderMailer.order_confirmation(order).deliver_now

    InventoryUpdateJob.perform_later(order.id)
  end
end
