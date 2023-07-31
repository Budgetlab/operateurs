require "test_helper"

class OrganismesControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get organismes_url
    assert_response :redirect
    assert_redirected_to new_user_session_path
  end
end
