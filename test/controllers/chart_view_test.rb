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

  private

  def t(date) = Time.zone.parse(date)

  def published(*dates)
    dates.each { |d| create(:article, published_at: t(d)) }
  end

  # Requests the chart and returns { bucket_label => count } from the rendered SVG.
  def chart(**params)
    get "/admin/articles", params: { view: "chart", **params }
    assert_response :success
    bars
  end

  def bars
    Nokogiri::HTML5(response.body).css("g.Chart-bar")
      .to_h { [ _1["data-bucket"], _1["data-count"].to_i ] }
  end
end
