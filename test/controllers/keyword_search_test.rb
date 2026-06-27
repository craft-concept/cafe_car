require "test_helper"

# Exercises the index search box end-to-end: the `q` param funnels through the
# query DSL into `QueryBuilder#search!` alongside the existing dot-filters + sort.
class KeywordSearchTest < ActionDispatch::IntegrationTest
  setup { sign_in }

  test "search box filters the index to matching records" do
    owner = create(:user)
    create(:client, name: "Zephyr Corp", owner:)
    create(:client, name: "Quokka LLC",  owner:)

    get "/admin/clients", params: { q: "zephyr" }

    assert_response :success
    assert_includes response.body, "Zephyr Corp"
    refute_includes response.body, "Quokka LLC"
  end

  test "the active term round-trips into the search box" do
    create(:client, name: "Zephyr Corp", owner: create(:user))

    get "/admin/clients", params: { q: "zephyr" }

    assert_select "form.search input[name=q][value=zephyr]"
  end

  test "search preserves dot-filters and sort" do
    owner = create(:user)
    create(:client, name: "Zephyr Corp", owner:)

    get "/admin/clients", params: { q: "zephyr", sort: "name", ".name" => "Zephyr Corp" }

    assert_response :success
    assert_includes response.body, "Zephyr Corp"
    # the search form carries the active filter + sort so resubmitting keeps them
    assert_select %(form.search input[type=hidden][name=".name"][value="Zephyr Corp"])
    assert_select "form.search input[type=hidden][name=sort][value=name]"
  end

  test "a custom scope :search still drives the box" do
    create(:article, title: "Zephyr rising", summary: "quokka hidden")

    # Article's custom scope only searches `title`, so a `summary`-only term misses.
    get "/admin/articles", params: { q: "quokka" }

    assert_response :success
    refute_includes response.body, "Zephyr rising"
  end
end
