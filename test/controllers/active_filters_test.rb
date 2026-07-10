require "test_helper"

# The active-filter chips (_active_filters): with filters + search + sort active,
# the index renders one removable chip per gated filter, each chip's remove link
# drops ONLY its own key (every other filter + q + sort survive), and clear-all
# drops all filter keys while keeping q + sort + view. Asserts the emitted hrefs,
# not just that chips render — a chip whose link forgets the other params would
# silently break composition with search/sort and the CSV/chart export.
class ActiveFiltersTest < ActionDispatch::IntegrationTest
  setup { @me = sign_in }

  # The chip row scoped for assert_select.
  def chips(path, params = {}, &block)
    get path, params: params
    assert_response :success
    assert_select "nav.ActiveFilters", &block
  end

  # The remove link href for the chip whose label matches `label`.
  def remove_href(label)
    css_select(".ActiveFilters-chip")
      .find { _1.at("span.ActiveFilters-label").text == label }
      &.at("a.ActiveFilters-remove")&.[]("href")
  end

  test "one chip per active filter, labelled and valued from the policy" do
    create(:client, owner: @me, status: :archived)

    chips "/admin/clients", "status" => "archived", "name~" => "acme" do
      assert_select ".ActiveFilters-chip", 2
      # Human label (not the raw `name~`/`status` key) + the submitted value.
      assert_select ".ActiveFilters-chip",
        text: /Status.*archived/
      assert_select ".ActiveFilters-chip",
        text: /Name.*acme/
    end
  end

  test "no chip row when nothing is filtered" do
    get "/admin/clients"
    assert_response :success
    assert_select "nav.ActiveFilters", 0
  end

  test "a chip's remove link drops its own key but keeps the other filter, q, and sort" do
    create(:client, owner: @me, status: :archived)

    get "/admin/clients",
      params: { "status" => "archived", "name~" => "acme", q: "hello", sort: "name" }
    assert_response :success

    href = remove_href("Status")
    params = Rack::Utils.parse_nested_query(URI(href).query)
    # Its own key is gone...
    assert_nil params["status"]
    # ...but the other filter, the search term, and the sort all ride along.
    assert_equal "acme",  params["name~"]
    assert_equal "hello", params["q"]
    assert_equal "name",  params["sort"]
  end

  test "clear-all drops every filter but keeps q, sort, and view" do
    create(:client, owner: @me, status: :archived)

    get "/admin/clients",
      params: { "status" => "archived", "name~" => "acme", q: "hello", sort: "name", view: "grid" }
    assert_response :success

    href   = css_select("a.ActiveFilters-clear").first["href"]
    params = Rack::Utils.parse_nested_query(URI(href).query)
    assert_nil params["status"]
    assert_nil params["name~"]
    assert_equal "hello", params["q"]
    assert_equal "name",  params["sort"]
    assert_equal "grid",  params["view"]
  end

  test "a belongs_to chip shows the associated record's title, not its raw id" do
    client = create(:client, name: "Acme Corp")
    create(:invoice, client:)

    chips "/admin/invoices", "client_id" => [ client.id ] do
      # The chip reads "Client: Acme Corp", never "Client: 42".
      assert_select ".ActiveFilters-chip", text: /Acme Corp/
      assert_select ".ActiveFilters-chip", text: /#{client.id}/, count: 0
    end
  end

  test "a nested belongs_to chip (client.owner) shows the owner's title" do
    owner = create(:user, name: "Jane Doe")
    client = create(:client, owner:)
    create(:invoice, client:)

    chips "/admin/invoices", "client.owner_id" => [ owner.id ] do
      assert_select ".ActiveFilters-chip", text: /Jane Doe/
    end
  end

  test "a has_many set chip shows every chosen record's title, resolved in one query" do
    invoice = create(:invoice, line_items: build_list(:line_item, 2))
    a, b = invoice.line_items.map(&:reload)
    # Line items title on their (currency-presented) amount — the same title the
    # membership select lists — for every id in the set, from one batched lookup.
    money = ->(n) { ActionController::Base.helpers.number_to_currency(n) }

    chips "/admin/invoices", "line_items.id" => [ a.id, b.id ] do
      assert_select ".ActiveFilters-chip", text: /#{Regexp.escape(money[a.amount])}/
      assert_select ".ActiveFilters-chip", text: /#{Regexp.escape(money[b.amount])}/
    end
  end

  test "an unresolvable (stale) association id falls back to the raw id" do
    create(:invoice)

    chips "/admin/invoices", "client_id" => [ "999999" ] do
      assert_select ".ActiveFilters-chip", text: /999999/
    end
  end

  test "a nested M2 filter (client.status) gets a chip whose remove link drops that path" do
    create(:invoice)

    get "/admin/invoices", params: { "client.status" => "archived", sort: "number" }
    assert_response :success

    # The nested filter labels off its terminal attribute ("Status") — the same
    # label the panel's nested control shows — and its value rides in the chip.
    assert_select ".ActiveFilters-chip", text: /Status.*archived/
    href   = remove_href("Status")
    params = Rack::Utils.parse_nested_query(URI(href).query)
    assert_nil params["client.status"]
    assert_equal "number", params["sort"]
  end
end
