class Admin::ReturnItemsController < ApplicationController
  before_action :authenticate_admin!
  before_action :set_return_item, only: [:show, :update]

  def index
    @return_items = ReturnItem.includes(order_item: { order: :customer }).order(created_at: :desc)
  end

  def show
  end

  def update
    if return_item_params[:status].present?
      @return_item.update(return_item_params)
      redirect_to admin_return_item_path(@return_item), notice: "Status updated."
    else
      redirect_to admin_return_item_path(@return_item)
    end
  end

  private

  def set_return_item
    @return_item = ReturnItem.find(params[:id])
  end

  def return_item_params
    params.require(:return_item).permit(:status)
  end
end
