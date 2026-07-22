require "test_helper"

module CafeCar
  # Status-ish attributes render as a colored Badge pill by convention:
  # `FieldInfo#badge?` (an ActiveRecord enum, or a string status/state column)
  # routes them through BadgePresenter from `Presenter#show`; everything else
  # renders exactly as before. Styles come from the locale's `badge.styles`
  # map — unknown values fall back to the neutral badge.
  class BadgePresenterTest < ActionView::TestCase
    helper CafeCar::Helpers

    setup do
      view.singleton_class.define_method(:policy) { |object| Pundit.policy!(nil, object) }
    end

    def badge(value) = view.present(value, as: :badge).to_s
    def show(object, method) = view.present(object).show(method).to_s

    test "Badge component renders a span with modifier classes" do
      assert_equal %(<span class="Badge Badge-info">Hi</span>), view.ui.Badge(:info, "Hi").to_s
    end

    test "renders a pill styled by the locale" do
      assert_equal %(<span class="Badge Badge-success">Published</span>), badge("published")
      assert_equal %(<span class="Badge Badge-danger">Archived</span>),   badge("archived")
    end

    test "unknown values render the neutral badge" do
      assert_equal %(<span class="Badge">Draft</span>),     badge("draft")
      assert_equal %(<span class="Badge">In review</span>), badge("in_review")
    end

    test "blank values render nothing" do
      assert_equal "", badge(nil)
      assert_equal "", badge("")
    end

    test "an enum attribute shows as a badge" do
      client = create(:client, status: :archived)

      assert_equal %(<span class="Badge Badge-danger">Archived</span>), show(client, :status)
    end

    test "a string status column shows as a badge" do
      user = create(:user) # status defaults to "active"

      assert_equal %(<span class="Badge Badge-success">Active</span>), show(user, :status)
    end

    test "non-status attributes are unaffected" do
      client = create(:client, name: "Acme Co")

      assert_equal "Acme Co", show(client, :name)
    end
  end
end
