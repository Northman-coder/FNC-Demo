require "test_helper"

class Admin::MessagesControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    sign_in admins(:one)
  end

  test "show marks message as read" do
    message = ContactMessage.create!(name: "Test", email: "test@example.com", message: "Hello", read: false)

    get admin_message_url(message)
    assert_response :success
    assert message.reload.read?
  end
end
