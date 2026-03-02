class AdminController < ApplicationController
  before_action :authenticate_admin!

  def show
    @admin = current_admin

    @tax_setting = TaxSetting.current

    @unread_messages_count = ContactMessage.unread.count
    @new_orders_count = Order.where(seen_by_admin: false).count
    @new_customers_count = Customer.where(seen_by_admin: false).count
  end
end
