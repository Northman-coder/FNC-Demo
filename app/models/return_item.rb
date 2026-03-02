class ReturnItem < ApplicationRecord
  belongs_to :order_item

  validates :quantity, numericality: { greater_than: 0 }
  validates :status, inclusion: { in: %w[pending approved rejected] }

  def product
    order_item.product
  end

  def order
    order_item.order
  end

  def customer
    order.customer
  end
end
