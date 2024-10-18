require "test_helper"

class EnqueteQuestionsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get enquete_questions_index_url
    assert_response :success
  end
end
