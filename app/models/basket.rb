class Basket
  def initialize(session)
    @session = session
    @session[:basket] ||= {}
  end

  def clear
    @session[:basket] = {}
  end

  def add(product, quantity = 1)
    id = product.id.to_s
    @session[:basket][id] = (@session[:basket][id] || 0) + quantity.to_i
  end

  def remove(product_id)
    @session[:basket].delete(product_id.to_s)
  end

  def update_quantity(product_id, quantity)
    quantity = quantity.to_i
    if quantity > 0
      @session[:basket][product_id.to_s] = quantity
    else
      remove(product_id)
    end
  end

  def items
    product_ids = @session[:basket].keys
    return [] if product_ids.empty?

    products = Product.where(id: product_ids).index_by { |p| p.id.to_s }
    @session[:basket].filter_map do |product_id, quantity|
      product = products[product_id]
      next unless product
      { product: product, quantity: quantity }
    end
  end

  def total_items
    @session[:basket].values.sum
  end

  def total_price
    items.sum { |item| item[:product].price * item[:quantity] }
  end

  def empty?
    @session[:basket].empty?
  end
end
