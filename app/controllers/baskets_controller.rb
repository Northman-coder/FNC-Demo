class BasketsController < ApplicationController
  before_action :reject_admin!
  before_action :ensure_catalog_open!, only: %i[add update remove]

  def show
    @basket = Basket.new(session)
  end

  def add
    product = Product.find(params[:product_id])
    quantity = (params[:quantity] || 1).to_i.clamp(1, 99)
    Basket.new(session).add(product, quantity)
    if params[:buy_now]
      redirect_to basket_path, notice: "#{product.name} added to basket."
    else
      redirect_back fallback_location: products_path, notice: "#{product.name} added to basket."
    end
  end

  def update
    quantity = params[:quantity].to_i.clamp(0, 99)
    Basket.new(session).update_quantity(params[:product_id], quantity)
    redirect_to basket_path
  end

  def remove
    Basket.new(session).remove(params[:product_id])
    redirect_to basket_path, notice: "Item removed from basket."
  end

  private

  def reject_admin!
    return unless admin_signed_in?

    redirect_to root_path, alert: "Admins cannot use the basket."
  end
end
