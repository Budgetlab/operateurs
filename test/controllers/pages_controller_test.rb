require "test_helper"

class PagesControllerTest < ActionDispatch::IntegrationTest
  test "unauthenticated user should not get index" do
    get root_url
    assert_response :redirect
    assert_redirected_to new_user_session_path
  end

  test "should get plan" do
    sign_in User.first
    get plan_url
    assert_response :success
  end
  test "should get accessibilite" do
    user = users(:one)
    sign_in user
    get accessibilite_url
    assert_response :success
  end
  test "should get mentions legales" do
    user = users(:one)
    sign_in user
    get mentions_legales_path
    assert_response :success
  end
  test "should get donnees personnelles" do
    user = users(:one)
    sign_in user
    get donnees_personnelles_path
    assert_response :success
  end
end
