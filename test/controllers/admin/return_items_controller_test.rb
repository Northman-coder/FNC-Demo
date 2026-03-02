require "test_helper"

class Admin::ReturnItemsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @admin = admins(:one)
    sign_in @admin
    @ri = return_items(:one)
  end

  test "should get index" do
    get admin_return_items_url
    assert_response :success
    assert_select "td", text: @ri.product.name
  end

  test "should show return" do
    get admin_return_item_url(@ri)
    assert_response :success
    assert_select "h1", text: "Return ##{@ri.id}"
    assert_select "p", /Customer:/
  end

  test "should update status" do
    patch admin_return_item_url(@ri), params: { return_item: { status: "approved" } }
    assert_redirected_to admin_return_item_path(@ri)
    assert_equal "approved", @ri.reload.status
  end
end
