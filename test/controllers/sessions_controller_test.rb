require "test_helper"

class SessionsControllerTest < ActionDispatch::IntegrationTest
  test "new renders the login form" do
    get "/session/new"

    assert_response :success
    assert_select "form[action='/session']"
  end

  test "show renders without a turbo stream for an unpersisted session" do
    get "/session"

    assert_response :success
  end

  test "failed login re-renders the form with an error" do
    create(:user, password: "secret", password_confirmation: "secret")

    post "/session", params: {session: {email: "nobody@example.com", password: "wrong"}}

    assert_response :unprocessable_content
    assert_select ".Error", /Could not find user/
    assert_nil cookies[:session_id].presence
  end

  test "successful login authenticates and redirects" do
    user = create(:user, password: "secret", password_confirmation: "secret")

    post "/session", params: {session: {email: user.email, password: "secret"}}

    assert_response :redirect
    assert_predicate cookies[:session_id], :present?
  end
end
