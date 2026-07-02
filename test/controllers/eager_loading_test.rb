require "test_helper"

# Guards against index N+1s: the scope pipeline must eager-load the belongs_to /
# has_many associations a table renders, so query count stays bounded instead of
# scaling with row count (the old `7 + 2N` fit).
#
# The trap this test avoids: if every row shared one associated record, AR's
# per-request query cache would collapse the association loads onto a single
# cached query and a *broken* (no-eager-load) implementation would look flat.
# So each row gets a DISTINCT association (a distinct owner per client).
class EagerLoadingTest < ActionDispatch::IntegrationTest
  test "clients index query count does not scale with row count" do
    queries_for_clients(1) # warm up one-time schema/session PRAGMA lookups

    small = queries_for_clients(3)
    large = queries_for_clients(10)

    assert_equal small, large,
      "clients index issued #{large} queries for 10 rows vs #{small} for 3 — " \
      "the :owner association (and its avatar) is not eager-loaded (N+1)"
  end

  private

  # Renders /admin/clients over `count` clients — each with its OWN owner so the
  # query cache can't mask a missing eager-load — and returns the SQL query count.
  def queries_for_clients(count)
    Client.delete_all
    count.times { create(:client, owner: create(:user)) }

    count_queries { get "/admin/clients" }
  end

  def count_queries
    queries = 0
    counter = ->(*, payload) { queries += 1 unless payload[:name] == "CACHE" }
    ActiveSupport::Notifications.subscribed(counter, "sql.active_record") { yield }
    queries
  end
end
