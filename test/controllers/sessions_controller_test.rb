require "test_helper"

class SessionsControllerTest < ActionDispatch::IntegrationTest
  test "should get create" do
    get sessions_create_url
    assert_response :success
  end

  test "should get destroy" do
    get sessions_destroy_url
    assert_response :success
  end

  test "should get destroy_sso" do
    get sessions_destroy_sso_url
    assert_response :success
  end

  test "should get sso" do
    get sessions_sso_url
    assert_response :success
  end
end
