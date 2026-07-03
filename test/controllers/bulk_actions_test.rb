require "test_helper"

# Bulk actions run each selected record through its OWN policy check: authorized
# rows are acted on, unauthorized rows are left untouched — never bulk-bypassed.
# ArticlePolicy protects PUBLISHED articles from deletion (see article_policy.rb),
# so a mixed batch exercises the per-record authorization boundary at the effect
# level (rows actually gone / still present in the DB), not just the response shape.
class BulkActionsTest < ActionDispatch::IntegrationTest
  setup { sign_in }

  test "bulk-delete removes authorized rows and leaves unauthorized ones" do
    drafts    = create_list(:article, 3, :draft)     # destroy? => true
    published = create_list(:article, 2, :published)  # destroy? => false

    post "/admin/articles/batch",
      params: { bulk_action: "destroy", ids: (drafts + published).map(&:id) }

    assert_redirected_to "/admin/articles"
    assert_empty Article.where(id: drafts.map(&:id)),
      "authorized draft rows should be deleted"
    assert_equal published.map(&:id).sort,
      Article.where(id: published.map(&:id)).pluck(:id).sort,
      "published rows are unauthorized and must survive the batch"
  end

  test "candidates load and authorize in a single query, not one per selected row" do
    [ 3, 8 ].each do |count|
      assert_equal 1, candidate_loads(count),
        "#{count}-row batch should load + authorize candidates with one WHERE id IN (...) " \
        "query; per-row loading would be an N+1"
    end
  end

  test "an unknown bulk action is a bad request" do
    post "/admin/articles/batch", params: { bulk_action: "nope", ids: [] }

    assert_response :bad_request
  end

  test "the index table renders selection checkboxes and a bulk-action bar" do
    create_list(:article, 2, :draft)

    get "/admin/articles"

    assert_response :success
    assert_select "input[type=checkbox][data-bulk-select-all]", 1
    assert_select "input[type=checkbox][name=?]", "ids[]", 2
    assert_select "form.BulkForm[id=BulkForm]", 1
  end

  test "the bulk-action button uses the locale label, sits in the toolbar, and hides until a row is selected" do
    create_list(:article, 2, :draft)

    get "/admin/articles"

    assert_response :success
    # Label comes from the locale (`en.destroy: Delete`), not the humanized action name.
    assert_select ".IndexToolbar .BulkActions button", { text: "Delete", count: 1 }
    # Hidden by default — revealed by JS only once a row is checked.
    assert_select ".BulkActions[hidden]", 1
    # The button submits the table's BulkForm from outside it, via the `form` attribute.
    assert_select ".BulkActions button[form=BulkForm][value=destroy]", 1
    # The bar shares the toolbar row with the search box.
    assert_select ".IndexToolbar form.search", 1
  end

  private

  # Runs a bulk-delete over `count` draft articles and returns how many candidate
  # SELECTs (`WHERE id IN (...)`) it issued. A correct impl loads and authorizes
  # every candidate in that one query, so the count stays 1 no matter the batch
  # size; per-row loading/authorizing would scale with `count`. (The subsequent
  # per-record DELETEs, and any reload their destroy callbacks trigger, are the
  # inherent cost of removing N records — deliberately not counted here.)
  def candidate_loads(count)
    Article.delete_all
    ids = create_list(:article, count, :draft).map(&:id)

    count_matching_queries(/FROM ["`]articles["`] WHERE .*\bIN\b/) do
      post "/admin/articles/batch", params: { bulk_action: "destroy", ids: }
    end
  end

  def count_matching_queries(pattern)
    count   = 0
    counter = ->(*, payload) do
      count += 1 if payload[:name] != "CACHE" && payload[:sql] =~ pattern
    end
    ActiveSupport::Notifications.subscribed(counter, "sql.active_record") { yield }
    count
  end
end
