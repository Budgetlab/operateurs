require "test_helper"

class MinisteresControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get ministeres_url
    assert_response :redirect
    assert_redirected_to new_user_session_path
  end
end
