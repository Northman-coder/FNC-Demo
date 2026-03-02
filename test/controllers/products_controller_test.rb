require "test_helper"

class ProductsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    # sign in an admin so that protected product actions succeed
    @admin = admins(:one)
    sign_in @admin
    @product = products(:one)

    # attach a dummy image so we can verify it isn't removed during edits
    @product.images.attach(
      io: File.open(Rails.root.join("test/fixtures/files/dummy.png")),
      filename: "dummy.png",
      content_type: "image/png"
    )
  end

  test "should get index and show recommendations without duplicates" do
    # ensure our fixture product has a discount so there is something to recommend
    assert @product.discounted?

    get products_url
    assert_response :success

    # product should appear in recommendations
    assert_select "#recommendations" do
      assert_select "[data-product-id='#{@product.id}']" do
        assert_select ".line-clamp-2", text: @product.name
      end
    end

    # and not in the main products block
    assert_select "#products" do
      assert_select "[data-product-id='#{@product.id}']", count: 0
    end
  end

  test "should get new" do
    get new_product_url
    assert_response :success
  end

  test "new arrivals page shows flagged products" do
    # ensure a product is marked new_arrival
    @product.update!(new_arrival: true)
    get new_arrivals_url
    assert_response :success
    assert_select "[data-product-id='#{@product.id}']"
  end

  test "exclusive deals page shows discounted products" do
    assert @product.discounted?
    get exclusive_deals_url
    assert_response :success
    assert_select "[data-product-id='#{@product.id}']"
  end

  test "brands index lists available brands" do
    @product.update!(brand: "Acme")
    get brands_url
    assert_response :success
    assert_select "a", text: "Acme"
  end

  test "brand page lists products by brand" do
    @product.update!(brand: "Acme")
    get brand_url("Acme")
    assert_response :success
    assert_select "[data-product-id='#{@product.id}']"
  end

  test "should create product" do
    assert_difference("Product.count") do
      post products_url, params: { product: { name: @product.name, price: @product.price, original_price: @product.original_price } }
    end

    new_product = Product.last
    assert_equal @product.original_price, new_product.original_price
    assert_redirected_to product_url(new_product)
  end

  test "should show product" do
    get product_url(@product)
    assert_response :success
  end

  test "should get edit" do
    get edit_product_url(@product)
    assert_response :success
  end

  test "should update product" do
    new_price = @product.price - 1
    assert_equal 1, @product.images.count, "precondition: image attached"

    patch product_url(@product), params: { product: { name: @product.name, price: new_price, original_price: @product.original_price } }
    assert_redirected_to product_url(@product)
    @product.reload
    assert_equal new_price, @product.price

    # images should remain untouched when none uploaded
    assert_equal 1, @product.images.count
  end

  test "should remove selected images when editing" do
    assert_equal 1, @product.images.count
    img = @product.images.first

    patch product_url(@product), params: { product: { name: @product.name, price: @product.price }, remove_images: [img.id] }
    assert_redirected_to product_url(@product)
    @product.reload
    assert_equal 0, @product.images.count
  end

  test "should destroy product" do
    # remove any order_items and return_items that reference the product so FKs don't trip
    # delete returns first (they depend on order_items)
    ReturnItem.joins(:order_item).where(order_items: { product_id: @product.id }).delete_all
    OrderItem.where(product: @product).delete_all

    assert_difference("Product.count", -1) do
      delete product_url(@product)
    end

    assert_redirected_to products_url
  end
end
