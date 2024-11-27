require "test_helper"

class ObjectifsContratsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get objectifs_contrats_index_url
    assert_response :success
  end
end
