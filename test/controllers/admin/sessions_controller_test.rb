require "test_helper"

class Admin::SessionsControllerTest < ActionDispatch::IntegrationTest
  # Signing in creates a session row, so this covers the index with data — the
  # case that 500ed whenever the table wasn't empty, because the top-level
  # `resource :session` (sign-in) shadowed the admin resource's row hrefs.
  test "sessions index renders with a session row" do
    sign_in

    get "/admin/sessions"

    assert_response :success
    assert_select "a[href=?]", "/admin/sessions/#{CafeCar::Session.last.id}"
  end
end
