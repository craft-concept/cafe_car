require "test_helper"

class CafeCar::FilterableTest < Minitest::Test
  def test_filter_attributes
    assert_includes Article.filtered(title: "bob").to_sql, %("title" = 'bob')
  end

  def test_filter_associations
    assert_includes Article.filtered(author: true).to_sql, %(EXISTS)
    assert_includes Article.filtered(author: {username: "bob"}).to_sql, %(EXISTS)
  end
end
