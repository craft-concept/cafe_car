require "test_helper"

# Exercises the advertised `?sort=name` / `?sort=-price` ordering and Kaminari
# `?page=` pagination through a real controller request. JSON is used so the
# assertions read the ordered collection directly.
class SortAndPaginateTest < ActionDispatch::IntegrationTest
  test "sort orders the collection ascending" do
    owner = create(:user)
    %w[Charlie Alpha Bravo].each { |n| create(:client, name: n, owner:) }

    get "/admin/clients", params: { sort: "name" }, as: :json

    assert_equal %w[Alpha Bravo Charlie], names
  end

  test "a leading dash sorts descending" do
    owner = create(:user)
    %w[Charlie Alpha Bravo].each { |n| create(:client, name: n, owner:) }

    get "/admin/clients", params: { sort: "-name" }, as: :json

    assert_equal %w[Charlie Bravo Alpha], names
  end

  # Client-supplied `?sort=` is allow-listed against real columns before it can
  # reach `reorder` — an unknown or malformed key is dropped, never raised, so a
  # crafted param can't trip Rails' dangerous-query guard into an unauth 500.
  test "an unknown association-looking key is dropped, not a 500" do
    seed_clients

    get "/admin/clients", params: { sort: "bogus.col" }, as: :json

    assert_response :success
    assert_equal 3, names.size
  end

  test "a malformed key with a trailing dot is dropped, not a 500" do
    seed_clients

    get "/admin/clients", params: { sort: "item." }, as: :json

    assert_response :success
    assert_equal 3, names.size
  end

  test "a multi-key sort applies only the valid columns" do
    seed_clients

    get "/admin/clients", params: { sort: "bogus.col,name" }, as: :json

    assert_response :success
    assert_equal %w[Alpha Bravo Charlie], names, "the invalid key is ignored, `name` still orders"
  end

  # A `?sort=` key must clear the same policy gate as a filter: a user may not
  # order by a column they may not filter by (ordering leaks a column's values
  # just as filtering does). UserPolicy#permitted_filters lists only name/
  # created_at, so email is off it.
  test "a non-permitted sort key is dropped, ordering falls back to the default" do
    sign_in
    # Names and emails are anti-correlated so the two orderings differ: gated out,
    # the model's `default_scope order(:name)` stands (Aaa before Zzz); honored,
    # email-asc would flip them (bbb before yyy).
    create(:user, name: "Zzz", email: "aaa@x.co")
    create(:user, name: "Aaa", email: "zzz@x.co")

    get "/admin/users", params: { sort: "email" }, as: :json

    assert_operator names.index("Aaa"), :<, names.index("Zzz"),
      "email is off permitted_filters — the key is ignored, name order stands"
  end

  test "a permitted sort key orders the collection" do
    sign_in
    create(:user, name: "Aaa")
    create(:user, name: "Zzz")

    get "/admin/users", params: { sort: "-name" }, as: :json

    assert_operator names.index("Zzz"), :<, names.index("Aaa"),
      "name is on permitted_filters — descending name order applies"
  end

  test "pagination limits per page and honors the page param" do
    owner = create(:user)
    9.times { |i| create(:client, name: "C%02d" % i, owner:) }

    get "/admin/clients", params: { sort: "name", per: 4, page: 1 }, as: :json
    assert_equal %w[C00 C01 C02 C03], names, "page 1 is limited to `per` records"

    get "/admin/clients", params: { sort: "name", per: 4, page: 2 }, as: :json
    assert_equal %w[C04 C05 C06 C07], names, "page 2 continues where page 1 left off"

    get "/admin/clients", params: { sort: "name", per: 4, page: 3 }, as: :json
    assert_equal %w[C08], names, "the final page holds the remainder"
  end

  test "an oversized `per` is silently clamped to CafeCar.max_per_page" do
    owner = create(:user)
    5.times { |i| create(:client, name: "C%02d" % i, owner:) }

    with_max_per_page(3) do
      get "/admin/clients", params: { sort: "name", per: 1_000_000 }, as: :json
    end

    assert_response :success
    assert_equal 3, names.size, "returns exactly the cap, not the whole table"
    assert_equal %w[C00 C01 C02], names
  end

  private

  def names = response.parsed_body.map { _1["name"] }

  def seed_clients
    owner = create(:user)
    %w[Charlie Alpha Bravo].each { |n| create(:client, name: n, owner:) }
  end

  def with_max_per_page(cap)
    original = CafeCar.max_per_page
    CafeCar.max_per_page = cap
    yield
  ensure
    CafeCar.max_per_page = original
  end
end
