require "test_helper"

# `cafe_car only:/except:` narrows the whole surface: an excluded action
# responds 404 — the same as its route not existing — never a raw 500 from
# `authorize!` with nothing loaded. The dummy's ReadonlyArticlesController is
# `cafe_car only: %i[index show]` with ALL routes drawn, so every request here
# hits the controller's own gate.
class NarrowingTest < ActionDispatch::IntegrationTest
  setup { sign_in }

  test "the narrowed-to actions still work" do
    article = create(:article)

    get "/admin/readonly_articles"
    assert_response :success

    get "/admin/readonly_articles/#{article.id}"
    assert_response :success
  end

  test "excluded CRUD actions respond 404 and change nothing" do
    article = create(:article)
    was     = article.attributes

    get "/admin/readonly_articles/new"
    assert_response :not_found

    post "/admin/readonly_articles", params: { article: { title: "New" } }
    assert_response :not_found

    patch "/admin/readonly_articles/#{article.id}", params: { article: { title: "Changed" } }
    assert_response :not_found

    delete "/admin/readonly_articles/#{article.id}"
    assert_response :not_found

    assert Article.exists?(article.id), "destroy must not run"
    assert_equal was, article.reload.attributes
    assert_equal 1, Article.count, "create must not run"
  end

  test "excluded CafeCar endpoints respond 404 and change nothing" do
    article = create(:article) # unpublished → publish!/publish_all! would take

    post "/admin/readonly_articles/batch", params: { bulk_action: "publish", ids: [ article.id ] }
    assert_response :not_found

    get "/admin/readonly_articles/options"
    assert_response :not_found

    post "/admin/readonly_articles/#{article.id}/actions/publish"
    assert_response :not_found

    post "/admin/readonly_articles/actions/publish_all"
    assert_response :not_found

    assert_not article.reload.published?, "no excluded endpoint may mutate"
  end
end
