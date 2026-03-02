require "test_helper"

class Admin::CustomersControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    sign_in admins(:one)
  end

  test "index marks customers as seen" do
    customer = Customer.create!(
      email: "newcustomer@example.com",
      password: "password1234",
      first_name: "New",
      last_name: "Customer",
      seen_by_admin: false
    )

    get admin_customers_url
    assert_response :success
    assert customer.reload.seen_by_admin
  end
end
