class Admin::CustomersController < ApplicationController
  before_action :authenticate_admin!

  def index
    @customers = Customer.order(created_at: :desc)

    Customer.where(seen_by_admin: false).update_all(seen_by_admin: true, updated_at: Time.current)
  end
end
