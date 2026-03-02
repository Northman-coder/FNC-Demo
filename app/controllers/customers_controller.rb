class CustomersController < ApplicationController
  before_action :authenticate_customer!

  def show
    @customer = current_customer
    @orders = @customer.orders.includes(:order_items).order(created_at: :desc)
  end
end
