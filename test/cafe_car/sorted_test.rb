require "test_helper"

module CafeCar
  class SortedTest < ActiveSupport::TestCase
    test "belongs_to key orders by the associated table's column, with the join" do
      owner = create(:user)
      beta  = create(:invoice, client: create(:client, name: "Beta",  owner:))
      alpha = create(:invoice, client: create(:client, name: "Alpha", owner:))

      sorted = Invoice.sorted("client.name")

      assert_includes sorted.to_sql, %(LEFT OUTER JOIN "clients")
      assert_includes sorted.to_sql, %(ORDER BY "clients"."name" ASC)
      assert_equal [ alpha, beta ], sorted.to_a
      assert_equal [ beta, alpha ], Invoice.sorted("-client.name").to_a
    end

    test "class_name association qualifies to the reflected table, not the assoc name" do
      assert_includes Invoice.sorted("sender.name").to_sql, %(LEFT OUTER JOIN "users")
      assert_includes Invoice.sorted("sender.name").to_sql, %(ORDER BY "users"."name")
    end

    test "unknown association or column is dropped to default order" do
      %w[bogus.name client.bogus item. client.name;DROP].each do |key|
        sql = Invoice.sorted(key).to_sql
        refute_includes sql, "ORDER BY", "#{key.inspect} must not reach reorder"
        refute_includes sql, "JOIN",     "#{key.inspect} must not build a join"
      end
    end
  end
end
