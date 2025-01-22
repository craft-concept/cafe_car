require "test_helper"

module CafeCar
  class QueryableTest < ActiveSupport::TestCase
    setup do
      create_list(:article, 3, :published)
      create_list(:article, 3, :draft, :sample_author)
    end

    test "query attributes" do
      assert_includes Article.query(title: "bob").to_sql, %("title" = 'bob')
      assert_includes Article.query(title!: "bob").to_sql, %("title" != 'bob')
    end

    test "query associations" do
      assert_includes Article.query(author: true).to_sql, %(EXISTS)
      assert_includes Article.query(author: {name: "bob"}).to_sql, %(EXISTS)
      assert_includes Article.query(author: {name: /bob/i}).to_sql, %(EXISTS)
    end

    test "query scopes" do
      refute_empty Article.query(published: true)
      refute_empty Article.query(draft: true)
      assert_empty Article.query(draft: true, published: true)
    end

    test "query count" do
      refute_empty User.query(articles: 1..5, name: /a/)
      assert_empty User.query(articles: 99)
      refute_empty User.query(articles!: 99)
    end

    # test "time spans" do
    #   assert_empty User.query("created_at >": "today")
    # end
  end
end
