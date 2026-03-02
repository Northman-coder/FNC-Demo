require "test_helper"

class CatalogOnlyModeTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @previous = Rails.configuration.x.catalog_only_mode
    Rails.configuration.x.catalog_only_mode = true

    @product = products(:one)
  end

  teardown do
    Rails.configuration.x.catalog_only_mode = @previous
  end

  test "blocks basket changes for guests" do
    post add_basket_path, params: { product_id: @product.id, quantity: 1 }
    assert_redirected_to root_path

    get basket_path
    assert_select "h2", text: "Your basket is empty"
  end

  test "allows basket changes for admins" do
    sign_in admins(:one)

    get basket_path
    assert_redirected_to root_path

    post add_basket_path, params: { product_id: @product.id, quantity: 1 }
    assert_redirected_to root_path
  end

  test "blocks checkout for customers" do
    sign_in customers(:one)

    post add_basket_path, params: { product_id: @product.id, quantity: 1 }
    post orders_path
    assert_redirected_to root_path
  end

  test "blocks contact message creation" do
    post contact_messages_path, params: { contact_message: { name: "Test", email: "test@example.com", message: "Hello" } }
    assert_redirected_to root_path
  end
end
