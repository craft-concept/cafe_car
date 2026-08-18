require "test_helper"

# The live demo auto-signs an anonymous visitor in as the seeded demo user
# (ApplicationController#enter_demo, gated on config.x.cafe_car_demo) so a
# policy-scoped index shows a populated admin on the first request instead of the
# empty set UserPolicy::Scope resolves for a nil user. The fix is identity, not a
# weakened policy — so these tests also pin that the scope still filters when the
# flag is off (it is NOT fail-open).
class DemoAutoSignInTest < ActionDispatch::IntegrationTest
  setup do
    User.create!(name: "Ada Demo", email: User::DEMO_EMAIL,
                 password: User::DEMO_PASSWORD, password_confirmation: User::DEMO_PASSWORD)
    create_list(:user, 3)
  end

  def with_demo(on)
    was = Rails.application.config.x.cafe_car_demo
    Rails.application.config.x.cafe_car_demo = on
    yield
  ensure
    Rails.application.config.x.cafe_car_demo = was
  end

  test "an anonymous visit to the demo lands signed in with a populated index" do
    with_demo(true) do
      get "/admin/users.json"
      users = JSON.parse(response.body)

      assert_response :success
      assert_operator users.size, :>, 1, "expected the populated seeded set, got #{users.size}"
      assert_predicate cookies[:session_id], :present?, "no session cookie was set"
      assert_includes users.map { _1["email"] }, User::DEMO_EMAIL
    end
  end

  test "with the demo flag off the policy scope still filters an anonymous request to empty" do
    with_demo(false) do
      get "/admin/users.json"
      users = JSON.parse(response.body)

      assert_response :success
      assert_empty users, "UserPolicy::Scope must stay closed for a nil user, not fail open"
      assert_nil cookies[:session_id].presence
    end
  end
end
