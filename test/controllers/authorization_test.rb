require "test_helper"
require "minitest/mock"

# How an authorization failure degrades depends on whether the host opted into
# CafeCar's sessions/login infrastructure (see DenialsController).
class AuthorizationTest < ActionDispatch::IntegrationTest
  test "denial returns 403, not 500, when sessions are unavailable" do
    # Simulates a CRUD-only host with no sessions migration/routes.
    CafeCar.stub :sessions_available?, false do
      get "/denials"

      assert_response :forbidden
    end
  end

  test "denial redirects to login when sessions are available and signed out" do
    get "/denials"

    assert_redirected_to new_session_path
  end

  test "denial redirects back when sessions are available and signed in" do
    sign_in

    get "/denials"

    assert_response :redirect
    assert_not_equal new_session_path, response.location
  end
end
