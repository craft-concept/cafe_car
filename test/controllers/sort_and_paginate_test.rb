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

  def with_max_per_page(cap)
    original = CafeCar.max_per_page
    CafeCar.max_per_page = cap
    yield
  ensure
    CafeCar.max_per_page = original
  end
end
