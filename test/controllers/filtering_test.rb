require "test_helper"

# Exercises the documented URL filter syntax end-to-end (README "Filtering &
# Sorting"): bare column keys with word-form operators route through the parser
# and query DSL. Before this, bare keys were a silent no-op — the index came
# back unfiltered — because only literal leading-dot keys reached the filter.
class FilteringTest < ActionDispatch::IntegrationTest
  setup do
    sign_in
    @client = create(:client, owner: create(:user))
    [ 5, 15, 25 ].each { |n| create(:invoice, client: @client, number: n) }
  end

  # Invoice numbers surviving a filter, sorted for a stable assertion.
  def numbers(filters)
    get "/admin/invoices.json", params: filters
    assert_response :success
    response.parsed_body.map { _1["number"] }.sort
  end

  test "a bare key filters by equality" do
    assert_equal [ 15 ], numbers("number" => 15)
  end

  test "min and max map to >= and <=" do
    assert_equal [ 15, 25 ], numbers("number.min" => 15)
    assert_equal [ 5, 15 ],  numbers("number.max" => 15)
  end

  test "gte and lte are aliases for min and max" do
    assert_equal [ 15, 25 ], numbers("number.gte" => 15)
    assert_equal [ 5, 15 ],  numbers("number.lte" => 15)
  end

  test "gt, lt, and eq comparison operators" do
    assert_equal [ 25 ], numbers("number.gt" => 15)
    assert_equal [ 5 ],  numbers("number.lt" => 15)
    assert_equal [ 15 ], numbers("number.eq" => 15)
  end

  test "min and max compose into a bounded range" do
    assert_equal [ 15 ], numbers("number.min" => 10, "number.max" => 20)
  end

  test "the .. range syntax filters between two bounds" do
    assert_equal [ 15 ], numbers("number" => "10..20")
  end

  test "a comma-separated value becomes an IN filter" do
    owner = create(:user)
    create(:client, name: "Alpha", owner:)
    create(:client, name: "Beta",  owner:)
    create(:client, name: "Gamma", owner:)

    get "/admin/clients.json", params: { "name" => "Alpha,Gamma" }

    assert_response :success
    assert_equal %w[Alpha Gamma], response.parsed_body.map { _1["name"] }.compact.sort
  end

  test "control params (sort, page, q) are never treated as filters" do
    # A model without a `sort`/`page` column must not raise when these arrive.
    get "/admin/invoices.json", params: { sort: "number", page: 1 }
    assert_response :success
    assert_equal [ 5, 15, 25 ], response.parsed_body.map { _1["number"] }.sort
  end

  # --- The policy gate: permitted_filters / permitted_scopes ---

  # Article titles surviving a filter on the admin articles index.
  def titles(filters)
    get "/admin/articles.json", params: filters
    assert_response :success
    response.parsed_body.map { _1["title"] }.sort
  end

  test "a hidden column param is ignored, not filtered" do
    # password_digest is stripped by Rails' parameter filter, so it's outside
    # permitted_filters — a param naming it must not narrow the result set.
    create_list(:user, 2)
    get "/admin/users.json", params: { "password_digest" => "nope" }
    assert_response :success
    assert_equal User.count, response.parsed_body.size
  end

  test "an unknown filter key is ignored, not an error" do
    assert_equal [ 5, 15, 25 ], numbers("bogus" => "1")
  end

  test "a permitted scope param invokes the scope" do
    published = create(:article, :published)
    create(:article, :draft)

    assert_equal [ published.title ], titles("published" => true)
  end

  test "a non-permitted scope param is ignored" do
    published = create(:article, :published)
    draft     = create(:article, :draft)

    # `unpublished` is a scope Article defines but ArticlePolicy doesn't list —
    # applied it would match nothing (both articles have a published_at);
    # ignored, the index stays whole.
    assert_equal [ draft.title, published.title ].sort, titles("unpublished" => true)
  end
end
