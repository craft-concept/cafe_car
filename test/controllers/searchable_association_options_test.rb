require "test_helper"

# Effect-level coverage for the searchable/remote association select. A `belongs_to`
# field renders a plain (capped) `<select>` tagged for Tom Select enhancement, backed
# by the model's `options` typeahead feed — so a value PAST `max_collection_options`
# is still reachable by keystroke, without leaking rows the policy hides.
class SearchableAssociationOptionsTest < ActionDispatch::IntegrationTest
  setup { @me = sign_in }

  # --- the point of the feature: reach a record past the render cap ------------

  test "the typeahead feed reaches a record past the render cap" do
    with_max_collection_options(3) do
      3.times { |i| create(:client, name: "Filler #{i}") }
      target = create(:client, name: "Zephyr Corp") # 4th row — beyond the cap

      # Un-searched, the capped feed stops at 3 rows and can't see the 4th.
      get "/admin/clients/options", as: :json
      assert_equal 3, values.size
      assert_not_includes values, target.id, "the target sits past the cap"

      # A keyword search narrows first, THEN caps — so the beyond-cap match surfaces.
      get "/admin/clients/options", params: { q: "zephyr" }, as: :json
      assert_includes values, target.id, "a matching row past the cap must be reachable"
    end
  end

  # --- authorization: the feed is policy-scoped --------------------------------

  test "the typeahead feed is policy-scoped, never leaking hidden rows" do
    hidden = create(:user, name: "Hidden Hank", email: "hank@example.com")

    # A non-super user's policy scope resolves to only itself (see UserPolicy::Scope).
    non_super do
      get "/admin/users/options", params: { q: "Hidden" }, as: :json
      assert_not_includes values, hidden.id, "policy_scope must hide a row the user can't see"

      get "/admin/users/options", params: { q: @me.name }, as: :json
      assert_includes values, @me.id, "a visible row is still returned"
    end
  end

  # --- the feed is bounded -----------------------------------------------------

  test "the typeahead feed is capped at the page size" do
    with_max_collection_options(3) do
      5.times { |i| create(:client, name: "Corp #{i}") }

      get "/admin/clients/options", params: { q: "Corp" }, as: :json
      assert_equal 3, values.size, "results are capped at max_collection_options"
    end
  end

  # --- rendering: the select carries the enhancement hook ----------------------

  test "an association select renders the Tom Select hook and its feed url" do
    client = create(:client, owner: create(:user))

    get url_for([ :edit, :admin, client ])

    assert_response :success
    assert_select "select[data-searchable-select][data-searchable-select-url='/admin/users/options']",
                  1, "the association select is flagged for enhancement and points at its feed"
  end

  private

  def values = response.parsed_body.map { _1["value"] }

  def with_max_collection_options(cap)
    original = CafeCar.max_collection_options
    CafeCar.max_collection_options = cap
    yield
  ensure
    CafeCar.max_collection_options = original
  end

  # The dummy app hardcodes `User#super? = true`; flip it so UserPolicy::Scope
  # actually narrows the readable set for the duration of the block.
  def non_super
    User.class_eval { def super? = false }
    yield
  ensure
    User.class_eval { def super? = true }
  end
end
