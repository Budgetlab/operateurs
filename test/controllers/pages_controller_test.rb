require "test_helper"

class PagesControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get root_url
    assert_response :success
  end
  test "should get plan" do
    get plan_url
    assert_response :success
  end
  test "should get accessibilite" do
    get accessibilite_url
    assert_response :success
  end
  test "should get mentions legales" do
    get mentions_legales_path
    assert_response :success
  end
  test "should get donnees personnelles" do
    get donnees_personnelles_path
    assert_response :success
  end
end
