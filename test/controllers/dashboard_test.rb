require "test_helper"

# The opt-in dashboard overview. A host defines it by WRITING one template —
# `app/views/cafe_car/dashboard/show.html.haml` — that composes the metric/chart
# helpers; its existence is the opt-in (no config DSL). The dummy app ships one
# (test/dummy/app/views/cafe_car/dashboard/show.html.haml), so the route is live
# here. These prove the policy-driven metrics reach the page, charts render, and an
# un-written dashboard 404s (and drops its nav link) rather than blanking.
class DashboardTest < ActionDispatch::IntegrationTest
  setup { sign_in }

  test "policy-driven metric tiles render their counts" do
    create_list(:article, 2, :draft)
    create(:article, :published)

    get "/admin/dashboard"

    assert_response :success
    # ArticlePolicy#permitted_metrics => %i[all published]: total, then published.
    assert_equal Article.count,             tiles[0]
    assert_equal Article.published.count,   tiles[1]
  end

  test "a chart tile renders an inline SVG bar per bucket" do
    create(:article, published_at: t("2026-01-10"), created_at: t("2026-01-10"))
    create(:article, published_at: t("2026-02-10"), created_at: t("2026-02-10"))

    get "/admin/dashboard"

    assert_response :success
    assert_select "svg.Chart"
    assert Nokogiri::HTML5(response.body).css(".Dashboard-chart g.Chart-bar").any?,
           "expected at least one chart bar"
  end

  test "the dashboard 404s when the host has not written the template" do
    without_dashboard_template do
      get "/admin/dashboard"
      assert_response :not_found
    end
  end

  test "the sidebar nav links to the dashboard when the template exists" do
    get "/admin/articles"

    assert_response :success
    assert_select "nav a[href=?]", "/admin/dashboard", text: /Dashboard/
  end

  test "the sidebar nav omits the dashboard link when no template exists" do
    without_dashboard_template do
      get "/admin/articles"

      assert_response :success
      assert_select "nav a[href=?]", "/admin/dashboard", count: 0
    end
  end

  private

  def t(date) = Time.zone.parse(date)

  # The rendered metric tile values, in order, as integers.
  def tiles
    Nokogiri::HTML5(response.body).css(".Metric-value").map { _1.text.strip.to_i }
  end

  # Temporarily hide the host dashboard template so the opt-in reads as "off",
  # clearing the view-lookup caches so the filesystem change is seen this request.
  def without_dashboard_template
    path  = Rails.root.join("app/views/cafe_car/dashboard/show.html.haml")
    moved = "#{path}.off"
    FileUtils.mv(path, moved)
    ActionView::LookupContext::DetailsKey.clear
    yield
  ensure
    FileUtils.mv(moved, path)
    ActionView::LookupContext::DetailsKey.clear
  end
end
