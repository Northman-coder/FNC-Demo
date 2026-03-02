class Admin::OrdersController < ApplicationController
  before_action :authenticate_admin!
  before_action :set_order, only: [:show, :update]

  def index
    @orders = Order.includes(:customer).order(created_at: :desc)

    if params[:status].present? && Order::STATUSES.include?(params[:status])
      @orders = @orders.where(status: params[:status])
    end

    @orders.where(seen_by_admin: false).update_all(seen_by_admin: true, updated_at: Time.current)
  end

  def show
    # nothing extra; template will display order details
    @order.update(seen_by_admin: true) unless @order.seen_by_admin?
    @contact_detail = ContactDetail.instance
  end

  def update
    previous_status = @order.status
    if @order.update(order_params)
      OrderMailer.order_status_update(@order).deliver_later if @order.status != previous_status
      redirect_to admin_order_path(@order), notice: "Order updated."
    else
      render :show, status: :unprocessable_entity
    end
  end

  private

  def set_order
    @order = Order.find(params[:id])
  end

  def order_params
    params.require(:order).permit(:status)
  end
end
