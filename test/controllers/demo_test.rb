require "test_helper"

# EFFECT-level coverage for the live demo (test/dummy): the "Enter the demo"
# login flow, PostHog user identification, and image rendering. These guard the
# owner-requested demo fixes (see DECISIONS.md 2026-07-04).
class DemoTest < ActionDispatch::IntegrationTest
  # --- Sessions / current_user (Task 2) -----------------------------------

  test "logging in yields a current_user on a later request" do
    sign_in create(:user, name: "Grace Hopper",
                          password: "secret", password_confirmation: "secret")

    get "/"

    assert_response :success
    assert_match "Signed in as Grace Hopper", response.body
  end

  test "the Enter the demo button signs in as the seeded demo account" do
    demo = create(:user, name: "Ada Demo", email: User::DEMO_EMAIL,
                         password: User::DEMO_PASSWORD, password_confirmation: User::DEMO_PASSWORD)

    get "/"
    assert_select "form[action='/session'] button", text: /Enter the demo/

    post "/session", params: { session: { email: User::DEMO_EMAIL, password: User::DEMO_PASSWORD } }
    follow_redirect!

    assert_match "Signed in as #{demo.name}", response.body
  end

  # --- PostHog identify (Task 1) ------------------------------------------

  test "identifies the logged-in user to posthog on the demo" do
    user = sign_in create(:user, name: "Alan Turing", email: "alan@example.com",
                                 password: "secret", password_confirmation: "secret")

    in_production { get "/" }

    assert_match %r{posthog\.identify\("#{user.id}"}, response.body
    assert_includes response.body, "alan@example.com"
  end

  test "no identify call renders for a logged-out visitor" do
    in_production { get "/" }

    assert_match "posthog.init(", response.body
    assert_no_match(/posthog\.identify/, response.body)
  end

  # --- Images (Task 3) -----------------------------------------------------

  test "seeded avatars are raster and render as an image" do
    user = create(:user)
    assert_predicate user.avatar, :representable?, "PNG avatar should render as an <img>, not a file figure"

    # Actually process a variant — the <img> tag renders regardless, but the
    # representation URL 500s at request time unless the :vips backend is
    # available (this is what broke images on the live demo). Prove it works.
    assert_nothing_raised { user.avatar.representation(resize_to_limit: [ 100, 100 ]).processed }

    sign_in user
    get "/admin/active_storage/attachments"

    assert_select "img"
  end

  private

  # Render as if on the deployed demo so the production-only PostHog snippet
  # (layouts/_posthog) is emitted.
  def in_production
    original = Rails.env
    Rails.env = "production"
    yield
  ensure
    Rails.env = original
  end
end
