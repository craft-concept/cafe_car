require "test_helper"

# Exercises the `respond_to :csv` index path. The CSV renderer reuses the JSON
# renderer's policy-respecting column basis (`[:id] | displayable_attributes`),
# narrowed to scalar columns, and exports the FULL filtered+sorted set (Kaminari
# pagination is skipped for CSV).
class CsvExportTest < ActionDispatch::IntegrationTest
  test "index renders text/csv with a header row and one row per record" do
    owner = create(:user)
    create(:client, name: "Alpha", owner:)
    create(:client, name: "Beta", owner:)

    get "/admin/clients.csv", params: { sort: "name" }

    assert_response :success
    assert_equal "text/csv", response.media_type

    # Scalar displayable columns only; `id` is prefixed, associations excluded.
    assert_equal %w[ID Name Status Created Updated], header
    assert_equal %w[Alpha Beta], names
  end

  test "non-displayable attributes are excluded (policy-respected)" do
    create(:client, name: "Alpha", owner: create(:user))

    get "/admin/clients.csv"

    # `owner_id` is mapped to the `owner` association by the policy, so it is not
    # a displayable scalar column and must not appear in the export.
    refute_includes header, "Owner id"
    refute_includes header, "Owner"
  end

  test "respects filters (exports the filtered subset only)" do
    owner = create(:user)
    create(:client, name: "Alpha", owner:)
    create(:client, name: "Beta", owner:)

    get "/admin/clients.csv", params: { "name" => "Alpha" }

    assert_equal %w[Alpha], names
  end

  test "exports beyond a single page (no pagination cap)" do
    owner = create(:user)
    9.times { |i| create(:client, name: "C%02d" % i, owner:) }

    get "/admin/clients.csv", params: { sort: "name", per: 4 }

    assert_equal 9, names.size, "all records export despite a per-page of 4"
    assert_equal "C00", names.first
    assert_equal "C08", names.last
  end

  test "text values that look like spreadsheet formulas are neutralized" do
    create(:client, name: '=HYPERLINK("http://evil")', owner: create(:user))

    get "/admin/clients.csv"

    # The leading `=` is prefixed with a quote so spreadsheets treat it as text.
    assert_equal %('=HYPERLINK("http://evil")), names.first
  end

  test "export under the row cap returns every row without a truncation signal" do
    owner = create(:user)
    3.times { |i| create(:client, name: "C%02d" % i, owner:) }

    with_csv_cap(5) { get "/admin/clients.csv", params: { sort: "name" } }

    assert_equal %w[C00 C01 C02], names
    assert_nil response.headers["X-CafeCar-Truncated"]
  end

  test "export over the row cap is truncated to exactly the cap and signals it" do
    owner = create(:user)
    5.times { |i| create(:client, name: "C%02d" % i, owner:) }

    with_csv_cap(3) { get "/admin/clients.csv", params: { sort: "name" } }

    assert_equal %w[C00 C01 C02], names, "exports exactly the cap, in sorted order"
    assert_equal "true", response.headers["X-CafeCar-Truncated"]
  end

  private

  def with_csv_cap(cap)
    original = CafeCar.csv_export_row_limit
    CafeCar.csv_export_row_limit = cap
    yield
  ensure
    CafeCar.csv_export_row_limit = original
  end

  def rows = CSV.parse(response.body)
  def header = rows.first
  def names
    name_col = header.index("Name")
    rows.drop(1).map { _1[name_col] }
  end
end
