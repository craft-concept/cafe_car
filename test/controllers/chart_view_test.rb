require "test_helper"
require "minitest/mock"

# Effect-level coverage of the index "chart" view: records are aggregated into
# time buckets over the SAME policy-scoped, filtered relation the table renders,
# and the x-axis column param is allowlisted (never interpolated into SQL).
class ChartViewTest < ActionDispatch::IntegrationTest
  setup { sign_in }

  test "aggregates record counts into the selected column's time buckets" do
    published "2026-01-15", "2026-01-20", "2026-03-02"

    assert_equal({ "2026-01" => 2, "2026-03" => 1 }, chart(chart_x: "published_at"))
  end

  test "day granularity buckets by calendar day" do
    published "2026-01-15", "2026-01-15", "2026-01-16"

    assert_equal({ "2026-01-15" => 2, "2026-01-16" => 1 },
                 chart(chart_x: "published_at", chart_by: "day"))
  end

  test "an active filter narrows the aggregation" do
    create(:article, title: "Keep", published_at: t("2026-01-10"))
    create(:article, title: "Drop", published_at: t("2026-02-10"))

    assert_equal({ "2026-01" => 1 }, chart(chart_x: "published_at", "title" => "Keep"))
  end

  test "policy_scope applies — hidden rows are not counted" do
    create(:article, title: "Visible", published_at: t("2026-01-10"))
    create(:article, title: "Hidden",  published_at: t("2026-02-10"))

    # Restrict the resolved scope to the visible row; the hidden row must not
    # reach the aggregation even though it exists.
    resolved      = Struct.new(:relation) { def resolve = relation }
    only_visible  = ->(_user, scope) { resolved.new(scope.where(title: "Visible")) }
    ArticlePolicy::Scope.stub(:new, only_visible) do
      assert_equal({ "2026-01" => 1 }, chart(chart_x: "published_at"))
    end
  end

  test "rows with a NULL x-axis value are dropped, not bucketed" do
    create(:article, title: "Dated",   published_at: t("2026-01-10"))
    create(:article, title: "Undated", published_at: nil)

    assert_equal({ "2026-01" => 1 }, chart(chart_x: "published_at"))
  end

  test "a non-datetime x-axis param falls back to a valid default (no SQL injection)" do
    published "2026-05-01"

    get "/admin/articles", params: { view: "chart", chart_x: "title); DROP TABLE articles;--" }

    assert_response :success
    # The bogus param was rejected by the allowlist; the chart fell back to the
    # default datetime column (created_at) instead of interpolating the param.
    assert_select "select#chart_x option[selected][value=?]", "created_at"
    assert Article.exists?, "articles table survived the injection attempt"
  end

  test "zero rows render an empty chart with an axis, not a divide-by-zero" do
    get "/admin/articles", params: { view: "chart", chart_x: "published_at" }

    assert_response :success
    assert_empty bars
    assert_select "line.Chart-axis", 1
  end

  # --- y-metric: sum / average of a numeric column (chart_y) -----------------

  test "sums a numeric column into the buckets (chart_y=sum:number)" do
    billed "2026-01-05" => 10, "2026-01-20" => 30, "2026-03-02" => 5

    assert_equal({ "2026-01" => 40, "2026-03" => 5 },
                 series("/admin/invoices", chart_x: "issued_on", chart_y: "sum:number"))
  end

  test "averages a numeric column into the buckets (chart_y=avg:number)" do
    billed "2026-01-05" => 10, "2026-01-15" => 30, "2026-02-01" => 100

    # Jan average = (10 + 30) / 2 = 20; Feb average = 100.
    assert_equal({ "2026-01" => 20, "2026-02" => 100 },
                 series("/admin/invoices", chart_x: "issued_on", chart_y: "avg:number"))
  end

  test "sums a decimal column and renders it as a clean number (chart_y=sum:total)" do
    client = create(:client)
    bill client, "2026-01-05", number: 1, total: 100.50
    bill client, "2026-01-20", number: 2, total: 200.50

    # 100.50 + 200.50 = 301.0 — a whole decimal sum collapses to 301, not "0.301e3".
    assert_equal({ "2026-01" => 301 },
                 series("/admin/invoices", chart_x: "issued_on", chart_y: "sum:total"))
  end

  test "chart_y defaults to a record count when absent" do
    billed "2026-01-05" => 10, "2026-01-20" => 30

    assert_equal({ "2026-01" => 2 }, series("/admin/invoices", chart_x: "issued_on"))
  end

  test "a non-permitted or unknown chart_y column is rejected, falling back to count" do
    billed "2026-01-05" => 10, "2026-01-20" => 30

    # `note` is a text column (not numeric/chartable) and the injection string is
    # not a column at all; both are dropped by the allowlist and fall back to a
    # plain record count instead of reaching SQL.
    assert_equal({ "2026-01" => 2 },
                 series("/admin/invoices", chart_x: "issued_on", chart_y: "sum:note"))
    assert_equal({ "2026-01" => 2 },
                 series("/admin/invoices", chart_x: "issued_on", chart_y: "sum:total) FROM invoices;--"))
    assert Invoice.exists?, "invoices table survived the injection attempt"
  end

  test "the y-metric selector only offers count when the model has no numeric column" do
    published "2026-01-10"
    get "/admin/articles", params: { view: "chart", chart_x: "published_at" }

    assert_select "select#chart_y", false, "no y-metric selector without a numeric column"
  end

  test "the y-metric selector offers a sum/avg per policy-permitted numeric column" do
    billed "2026-01-05" => 10
    get "/admin/invoices", params: { view: "chart", chart_x: "issued_on" }

    assert_select "select#chart_y option[value=?]", "sum:total"
    assert_select "select#chart_y option[value=?]", "avg:number"
    # A non-numeric column is never offered as an aggregate.
    assert_select "select#chart_y option[value=?]", "sum:note", false
  end

  private

  def t(date) = Time.zone.parse(date)

  def published(*dates)
    dates.each { |d| create(:article, published_at: t(d)) }
  end

  # Creates one invoice per `issued_on => number` pair (numbers stay unique per the
  # shared client), with `total` defaulting to the number so a sum/avg over either
  # column is deterministic.
  def billed(dates)
    client = @client ||= create(:client)
    dates.each { |date, number| bill(client, date, number:, total: number) }
  end

  # One invoice with `issued_on`/`number`/`total` written past the model callbacks
  # (which otherwise auto-assign `number` and recompute `total` from line items).
  def bill(client, date, number:, total:)
    create(:invoice, client:, line_items: [ build(:line_item) ])
      .update_columns(issued_on: Date.parse(date), number:, total:)
  end

  # Requests the chart at `path` and returns { bucket_label => y_value } from the SVG.
  def series(path = "/admin/articles", **params)
    get path, params: { view: "chart", **params }
    assert_response :success
    bars
  end
  alias chart series

  def bars
    Nokogiri::HTML5(response.body).css("g.Chart-bar")
      .to_h { [ _1["data-bucket"], num(_1["data-value"]) ] }
  end

  # The SVG carries whole values with no decimal point (a count, or 301 from 301.0);
  # a fractional aggregate keeps its point. Parse back to the matching numeric type.
  def num(str) = str.include?(".") ? str.to_f : str.to_i
end
