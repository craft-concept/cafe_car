require "test_helper"

# The opt-in dashboard overview: a host declares metric tiles + charts via
# `CafeCar.dashboard { ... }`; the engine renders them in a grid. The dummy app
# declares a demo dashboard (test/dummy/config/initializers/cafe_car_dashboard.rb),
# so the route is live here. These prove the DSL registers widgets, the widgets
# reach the rendered page, and an un-configured dashboard 404s rather than blanks.
class DashboardTest < ActionDispatch::IntegrationTest
  setup { sign_in }

  test "the DSL registers metric and chart widgets in declared order" do
    dashboard = CafeCar::Dashboard.new
    dashboard.metric "Users", -> { 42 }
    dashboard.chart  "New", model: Article, x: :created_at, by: :month

    assert_equal %i[metric chart], dashboard.widgets.map(&:type)
    assert_equal "Users", dashboard.widgets.first.label
    assert_equal 42,      dashboard.widgets.first.call
    assert_equal :created_at, dashboard.widgets.last.x
  end

  test "a metric tile renders its callable's number" do
    get "/admin/dashboard"

    assert_response :success
    values = tiles
    assert_equal Article.count,                          values[0]
    assert_equal Article.where.not(published_at: nil).count, values[1]
  end

  test "a chart widget renders an inline SVG bar per bucket" do
    create(:article, published_at: t("2026-01-10"), created_at: t("2026-01-10"))
    create(:article, published_at: t("2026-02-10"), created_at: t("2026-02-10"))

    get "/admin/dashboard"

    assert_response :success
    assert_select "svg.Chart"
    assert Nokogiri::HTML5(response.body).css(".Dashboard-chart g.Chart-bar").any?,
           "expected at least one chart bar"
  end

  test "the dashboard 404s when no dashboard is configured" do
    with_dashboard(nil) do
      get "/admin/dashboard"
      assert_response :not_found
    end
  end

  private

  def t(date) = Time.zone.parse(date)

  # The rendered metric tile values, in order, as integers.
  def tiles
    Nokogiri::HTML5(response.body).css(".Metric-value").map { _1.text.strip.to_i }
  end

  def with_dashboard(config)
    saved = CafeCar.dashboard_config
    CafeCar.dashboard_config = config
    yield
  ensure
    CafeCar.dashboard_config = saved
  end
end
