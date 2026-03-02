require "test_helper"

class Admin::SalesControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @admin = admins(:one)
  end

  test "redirects when not signed in" do
    get admin_sales_url
    assert_response :redirect
  end

  test "shows sales when signed in" do
    sign_in @admin
    get admin_sales_url
    assert_response :success
    assert_select "h1", "Sales"
  end
end
