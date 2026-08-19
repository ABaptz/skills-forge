require "test_helper"

class ChatsControllerTest < ActionDispatch::IntegrationTest
  test "should get create" do
    get chats_create_url
    assert_response :success
  end
end
