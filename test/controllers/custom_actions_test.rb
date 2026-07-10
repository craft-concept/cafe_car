require "test_helper"

# Custom actions are policy-declared (permitted_member_actions /
# permitted_collection_actions) and derived from the name: the `name?`
# predicate authorizes and `name!` runs — member on the record, collection on
# the policy scope. These tests assert the persisted effect and the
# authorization boundary, not just response shapes.
class CustomActionsTest < ActionDispatch::IntegrationTest
  setup { sign_in }

  test "a member action runs the record's bang method and redirects back to it" do
    article = create(:article) # unpublished → publish? => true

    post "/admin/articles/#{article.id}/actions/publish"

    assert_redirected_to "/admin/articles/#{article.id}"
    assert article.reload.published?, "publish! should have set published_at"
  end

  test "an unauthorized member action is refused and changes nothing" do
    article = create(:article, :published) # publish? => false
    was     = article.published_at

    post "/admin/articles/#{article.id}/actions/publish"

    assert_response :redirect # render_unauthorized bounces; publish! never ran
    assert_equal was, article.reload.published_at
  end

  test "a member action outside permitted_member_actions is not found" do
    article = create(:article)

    # `destroy` has a predicate and a bang method, but it is not whitelisted as
    # a member action — the policy list is the gate, not the model's methods.
    post "/admin/articles/#{article.id}/actions/destroy"

    assert_response :not_found
    assert Article.exists?(article.id), "the unlisted action must not run"
  end

  test "a collection action runs the class bang method over the whole scope when unfiltered" do
    unpublished = create_list(:article, 3)

    post "/admin/articles/actions/publish_all"

    assert_redirected_to "/admin/articles"
    assert unpublished.all? { _1.reload.published? },
      "publish_all! should publish every unpublished article"
  end

  test "a collection action runs only over the filtered view, not the whole scope" do
    mine   = create(:user)
    in_view = create_list(:article, 2, author: mine)
    hidden  = create_list(:article, 2, author: create(:user))

    # The filter rides the URL query string, exactly as the toolbar button posts it.
    post "/admin/articles/actions/publish_all?author_id=#{mine.id}"

    assert_redirected_to "/admin/articles"
    assert in_view.all? { _1.reload.published? }, "the filtered articles are published"
    assert hidden.none?  { _1.reload.published? }, "articles outside the filter are untouched"
  end

  test "the collection-action button carries the active filter and shows its count" do
    mine = create(:user)
    create_list(:article, 2, author: mine)
    create_list(:article, 3, author: create(:user)) # outside the filter

    get "/admin/articles", params: { author_id: mine.id }

    assert_response :success
    assert_select "form[action=?] button",
      "/admin/articles/actions/publish_all?author_id=#{mine.id}", text: "Publish all 2", count: 1
  end

  test "a collection action outside permitted_collection_actions is not found" do
    article = create(:article)

    post "/admin/articles/actions/publish" # a member-only name

    assert_response :not_found
    assert_not article.reload.published?
  end

  test "a host-defined controller method overrides the default bang forwarding" do
    Admin::ArticlesController.define_method(:publish) do
      redirect_to url_for(action: :index)
    end
    article = create(:article)

    post "/admin/articles/#{article.id}/actions/publish"

    assert_redirected_to "/admin/articles"
    assert_not article.reload.published?, "the override replaces publish! forwarding"
  ensure
    Admin::ArticlesController.remove_method(:publish)
  end

  test "the show page's Actions card offers member actions as POST links" do
    article = create(:article)

    get "/admin/articles/#{article.id}"

    assert_response :success
    assert_select "a[data-turbo-method=post][href=?]",
      "/admin/articles/#{article.id}/actions/publish", text: "Publish", count: 1
  end

  test "a denied member action renders disabled on the show page, not as a link" do
    article = create(:article, :published) # publish? => false

    get "/admin/articles/#{article.id}"

    assert_response :success
    assert_select "a[href=?]", "/admin/articles/#{article.id}/actions/publish", 0
    assert_select "span.disabled", text: "Publish", count: 1
  end

  test "index rows offer member actions and the toolbar offers collection actions" do
    article = create(:article)

    get "/admin/articles"

    assert_response :success
    assert_select "a[data-turbo-method=post][href=?]",
      "/admin/articles/#{article.id}/actions/publish", text: "Publish", count: 1
    assert_select "form[action=?] button", "/admin/articles/actions/publish_all",
      text: "Publish all 1", count: 1
  end
end
