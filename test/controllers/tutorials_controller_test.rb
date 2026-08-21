require "test_helper"

class TutorialsControllerTest < ActionDispatch::IntegrationTest
  test "should get claude" do
    get tutorials_claude_url
    assert_response :success
  end

  test "should get chatgpt" do
    get tutorials_chatgpt_url
    assert_response :success
  end

  test "should get gemini" do
    get tutorials_gemini_url
    assert_response :success
  end
end
