require "test_helper"
require "minitest/mock"

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

    post "/session", params: { session: { email: "nobody@example.com", password: "wrong" } }

    assert_response :unprocessable_content
    assert_select ".Error", /Could not find user/
    assert_nil cookies[:session_id].presence
  end

  test "successful login authenticates and redirects" do
    user = create(:user, password: "secret", password_confirmation: "secret")

    post "/session", params: { session: { email: user.email, password: "secret" } }

    assert_response :redirect
    assert_predicate cookies[:session_id], :present?
    cookie_headers = Array(response.headers["Set-Cookie"]).join("\n")
    assert_match(/httponly/i, cookie_headers)
    assert_match(/samesite=lax/i, cookie_headers)
    assert_no_match(/expires|max-age/i, cookie_headers)
  end

  test "the session cookie is secure in production" do
    user = create(:user, password: "secret", password_confirmation: "secret")
    https!

    Rails.env.stub(:production?, true) do
      post "/session", params: { session: { email: user.email, password: "secret" } }
    end

    assert_match(/; secure/i, Array(response.headers["Set-Cookie"]).join("\n"))
  end

  test "successful login rotates an existing session" do
    user = sign_in
    previous = CafeCar::Session.last

    post "/session", params: { session: { email: user.email, password: "secret" } }

    assert_response :redirect
    assert_not_equal previous.id, CafeCar::Session.last.id
    assert_not CafeCar::Session.exists?(previous.id)
  end

  test "failed reauthentication preserves the existing session" do
    user = sign_in
    previous = CafeCar::Session.last

    post "/session", params: { session: { email: user.email, password: "wrong" } }

    assert_response :unprocessable_content
    assert CafeCar::Session.exists?(previous.id)
  end

  test "successful login preserves the requested return location" do
    user = create(:user, password: "secret", password_confirmation: "secret")
    get "/denials"

    post "/session", params: { session: { email: user.email, password: "secret" } }

    assert_redirected_to "http://www.example.com/denials"
  end

  test "a stale session cookie is cleared and treated as signed out" do
    sign_in
    CafeCar::Session.delete_all

    get "/denials"

    assert_redirected_to new_session_path
    assert_nil cookies[:session_id].presence
  end

  test "an idle session expires server-side" do
    sign_in
    record = CafeCar::Session.last
    record.update_column(:updated_at, CafeCar::Session::IDLE_LIFETIME.ago - 1.second)

    get "/denials"

    assert_redirected_to new_session_path
    assert_not CafeCar::Session.exists?(record.id)
    assert_nil cookies[:session_id].presence
  end

  test "an old session expires even if recently active" do
    sign_in
    record = CafeCar::Session.last
    record.update_columns(created_at: CafeCar::Session::ABSOLUTE_LIFETIME.ago - 1.second,
                          updated_at: Time.current)

    get "/denials"

    assert_redirected_to new_session_path
    assert_not CafeCar::Session.exists?(record.id)
  end

  test "an authenticated request renews the idle lifetime" do
    sign_in
    record = CafeCar::Session.last
    record.update_column(:updated_at, 1.hour.ago)

    get "/admin/clients"

    assert_operator record.reload.updated_at, :>, 1.minute.ago
  end

  test "logout destroys the session and clears the cookie" do
    sign_in
    assert_predicate cookies[:session_id], :present?

    delete "/session"

    assert_response :redirect
    assert_nil cookies[:session_id].presence
  end

  test "the engine also provides the session route when mounted" do
    get "/admin/session/new"

    assert_response :success
  end
end
