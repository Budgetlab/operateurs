require "test_helper"

class EnqueteReponsesControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get enquete_reponses_index_url
    assert_response :success
  end
end
