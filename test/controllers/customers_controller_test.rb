require "test_helper"

class CustomersControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers
  include ActionView::Helpers::NumberHelper

  setup do
    @customer = customers(:one)
  end

  test "redirects to login when not signed in" do
    get account_path
    assert_redirected_to new_customer_session_path
  end

  test "shows account page with details and orders" do
    sign_in @customer
    get account_path
    assert_response :success
    assert_select "h1", "My Account"
    assert_select "p", text: /#{@customer.full_name}/
    assert_select "p", text: /#{@customer.email}/
    # order information should be present
    assert_select "td", text: number_to_currency(orders(:one).total_price)
    assert_select "td", text: number_to_currency(orders(:two).total_price)
  end
end
