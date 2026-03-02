# frozen_string_literal: true

class InventoryUpdateJob < ApplicationJob
  queue_as :default

  def perform(order_id)
    order = Order.includes(order_items: :product).find(order_id)

    order.order_items.each do |order_item|
      product = order_item.product

      # This app currently doesn't have a stock quantity column.
      # If you add one later (e.g. `stock_quantity`), this job can decrement it.
      next unless product.respond_to?(:stock_quantity)

      product.with_lock do
        product.stock_quantity = product.stock_quantity.to_i - order_item.quantity.to_i
        product.save!
      end
    end
  end
end
