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

  # A fresh CRUD-only host has no sessions table, so instantiating a session
  # raises. current_user (Pundit's default pundit_user) is evaluated during
  # authorization on every request; it must consult the sessions gate and
  # return nil instead of 500ing. Here the request reaches the controller
  # cleanly (the denial tests above cover the 403/redirect degradation shape).
  test "current_user does not 500 when the sessions table is absent" do
    CafeCar.stub :sessions_available?, false do
      CafeCar::Session.stub :new, proc { raise ActiveRecord::StatementInvalid, "no such table: sessions" } do
        get "/admin/clients"

        assert_response :success
      end
    end
  end
end
