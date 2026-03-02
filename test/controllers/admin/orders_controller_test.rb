require "test_helper"

class Admin::OrdersControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @admin = admins(:one)
    sign_in @admin
    @order = orders(:one)
  end

  test "should get index" do
    get admin_orders_url
    assert_response :success
    assert_includes @response.body, @order.order_number
  end

  test "should show order" do
    get admin_order_url(@order)
    assert_response :success
    assert_includes @response.body, @order.order_number
    assert_includes @response.body, orders(:one).order_items.first.product.name
  end

  test "should update order status" do
    patch admin_order_url(@order), params: { order: { status: "shipped" } }
    assert_redirected_to admin_order_url(@order)
    assert_equal "shipped", @order.reload.status
  end

  test "index marks orders as seen" do
    new_order = Order.create!(customer: customers(:one), total_price: 10.0, status: "pending", seen_by_admin: false)
    get admin_orders_url
    assert_response :success
    assert new_order.reload.seen_by_admin
  end

  test "index can filter cancelled orders" do
    cancelled = Order.create!(customer: customers(:one), total_price: 5.0, status: "cancelled")
    get admin_orders_url(status: "cancelled")
    assert_response :success
    assert_includes @response.body, cancelled.order_number
    refute_includes @response.body, orders(:one).order_number
  end
end
