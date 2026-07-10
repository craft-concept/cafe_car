require "test_helper"

module CafeCar
  class QueryableTest < ActiveSupport::TestCase
    setup do
      create_list(:article, 3, :published)
      create_list(:article, 3, :draft)
    end

    test "query attributes" do
      assert_includes Article.query(title: "bob").to_sql, %("title" = 'bob')
      assert_includes Article.query(title!: "bob").to_sql, %("title" != 'bob')
    end

    test "query associations" do
      assert_includes Article.query(author: true).to_sql, %(EXISTS)
      assert_includes Article.query(author: { name: "bob" }).to_sql, %(EXISTS)
      assert_includes Article.query(author: { name: /bob/i }).to_sql, %(EXISTS)
    end

    test "query scopes" do
      refute_empty Article.query(published: true)
      refute_empty Article.query(draft: true)
      assert_empty Article.query(draft: true, published: true)
    end

    test "query count" do
      refute_empty User.query(articles: 1..50, name: /./)
      assert_empty User.query(articles: 99)
      refute_empty User.query(articles!: 99)
    end

    # test "time spans" do
    #   assert_empty User.query("created_at >": "today")
    # end

    test "enum keys filter integer-backed enums to the right bucket" do
      live = create(:client, status: :active)
      old  = create(:client, status: :archived)

      assert_equal [ old ],  Client.query(status: "archived").to_a
      assert_equal [ live ], Client.query(status: "active").to_a
      assert_includes Client.query(status: "archived").to_sql, %("status" = 1)
    end

    test "non-enum integer columns still coerce string params" do
      invoice = create(:invoice)

      assert_equal [ invoice ], Invoice.query(number: invoice.number.to_s).to_a
      assert_includes Invoice.query(number: "42").to_sql, %("number" = 42)
    end

    test "default search matches string/text columns case-insensitively" do
      owner = create(:user)
      alpha = create(:client, name: "Alpha Corp", owner:)
      beta  = create(:client, name: "Beta LLC",   owner:)

      assert_equal [ alpha ], Client.query("alpha").to_a
      assert_equal [ alpha ], Client.query("ALPHA").to_a
      assert_empty Client.query("nomatch")
      assert_includes Client.query("alpha").to_sql, %("clients"."name")
    end

    test "default search spans every searchable column" do
      invoice = create(:invoice, note: "urgent rush job")

      assert_equal [ invoice ], Invoice.query("rush").to_a
    end

    test "custom scope :search takes precedence over the default" do
      bob = create(:article, title: "Bob writes", summary: "nothing here")
      create(:article, title: "Other", summary: "mentions bob deep inside")

      # Article's custom scope only searches `title`; the default would also hit `summary`.
      assert_equal [ bob ], Article.query("bob").to_a
    end

    test "searchable columns exclude parameter-filtered columns (policy-respected)" do
      assert_equal %w[email name], User.searchable_columns.sort
      refute_includes User.searchable_columns, "password_digest"
    end
  end
end
