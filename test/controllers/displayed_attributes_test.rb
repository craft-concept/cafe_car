require "test_helper"

class DisplayedAttributesTest < ActionDispatch::IntegrationTest
  test "policy overrides hide a custom sensitive field from default HTML JSON and CSV" do
    secret = "private editorial note"
    article = create(:article, summary: secret)

    without_article_summary do
      get "/admin/articles"
      assert_response :success
      assert_select "th", text: "Summary", count: 0
      refute_includes response.body, secret

      get "/admin/articles/#{article.id}.json"
      assert_response :success
      refute response.parsed_body.key?("summary")
      refute_includes response.body, secret

      get "/admin/articles.csv"
      assert_response :success
      refute_includes CSV.parse(response.body).first, "Summary"
      refute_includes response.body, secret
    end
  end

  private

  def without_article_summary
    displayable = ArticlePolicy.instance_method(:displayable_attributes)
    listable    = ArticlePolicy.instance_method(:listable_attributes)

    ArticlePolicy.define_method(:displayable_attributes) do
      displayable.bind_call(self) - %i[summary]
    end
    ArticlePolicy.define_method(:listable_attributes) do
      listable.bind_call(self) - %i[summary]
    end
    yield
  ensure
    ArticlePolicy.define_method(:displayable_attributes, displayable)
    ArticlePolicy.define_method(:listable_attributes, listable)
  end
end
