require "test_helper"

class CafeCar::QueryableTest < ActiveSupport::TestCase
  test "query attributes" do
    assert_includes Article.query(title: "bob").to_sql, %("title" = 'bob')
  end

  test "query associations" do
    assert_includes Article.query(author: true).to_sql, %(EXISTS)
    assert_includes Article.query(author: {username: "bob"}).to_sql, %(EXISTS)
    assert_includes Article.query(author: {username: /bob/}).to_sql, %(EXISTS)
  end
end
