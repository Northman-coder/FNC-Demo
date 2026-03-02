require "test_helper"

class OrdersControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers
  include ActionView::Helpers::NumberHelper

  setup do
    @customer = customers(:one)
    @other_customer = customers(:two)
    @order = orders(:one)
    # create a separate order record for the other customer instead of relying on fixture
    @other_order = Order.create!(customer: @other_customer, total_price: 10.0, status: "pending")
  end

  test "redirects to login when not signed in" do
    get orders_path
    assert_redirected_to new_customer_session_path
  end

  test "index shows only current customer's orders" do
    sign_in @customer
    get orders_path
    assert_response :success
    assert_includes @response.body, number_to_currency(@order.total_with_tax)
    refute_includes @response.body, number_to_currency(@other_order.total_with_tax)
  end

  test "show own order" do
    sign_in @customer
    get order_path(@order)
    assert_response :success
    assert_includes @response.body, @order.order_number
  end

  test "cannot show another customer's order" do
    sign_in @customer
    get order_path(@other_order)
    assert_response :not_found
  end

  test "checkout creates an order from the basket and clears it" do
    sign_in @customer

    product = products(:one)
    post add_basket_path, params: { product_id: product.id, quantity: 2 }
    assert_response :redirect

    assert_difference("Order.count", 1) do
      assert_difference("OrderItem.count", 1) do
        post orders_path
      end
    end

    order = Order.order(:created_at).last
    assert_redirected_to pay_order_path(order)
    assert_equal @customer.id, order.customer_id
    assert_equal "pending", order.status
    assert_in_delta (product.price.to_d * 2).to_f, order.total_price.to_f, 0.01

    item = order.order_items.first
    assert_equal product.id, item.product_id
    assert_equal 2, item.quantity
    assert_in_delta product.price.to_f, item.unit_price.to_f, 0.01

    get basket_path
    assert_response :success
    assert_select "h2", text: "Your basket is empty"
  end

  test "customer can cancel their pending order" do
    sign_in @customer

    order = Order.create!(customer: @customer, total_price: 10.0, status: "pending")
    patch cancel_order_path(order)

    assert_redirected_to order_path(order)
    assert_equal "cancelled", order.reload.status
  end

  test "customer cannot cancel a shipped order" do
    sign_in @customer

    shipped_order = orders(:two)
    assert_equal "shipped", shipped_order.status

    patch cancel_order_path(shipped_order)
    assert_redirected_to order_path(shipped_order)
    assert_equal "shipped", shipped_order.reload.status
  end
end
