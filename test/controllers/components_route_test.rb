require "test_helper"

# The `components` UI gallery (ExamplesController#index) skips policy/authorization
# and is a development-only demo. It must NOT be mounted in a non-development env,
# so a host app never inherits an unauthenticated, public route in production.
class ComponentsRouteTest < ActionDispatch::IntegrationTest
  test "the components gallery is not routable outside development" do
    refute Rails.env.development?, "guard assumes the test env is not development"

    get "/admin/components"

    assert_response :not_found
  end
end
