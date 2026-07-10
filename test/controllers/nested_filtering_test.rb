require "test_helper"

# Nested-association filters (Filtering M2): a policy permits a dot-path
# (`client.status`, `client.owner`) and the index filters by the FAR model's
# attribute, composing the same join the query DSL builds for a top-level filter.
# The security half — a nested param is honored ONLY when its FULL path is
# permitted — gets the same rigor as the one-level gate: an undeclared path,
# even one naming a real far column, never reaches SQL.
#
# InvoicePolicy declares `%i[client.status client.owner]`. Invoice belongs_to
# client; Client has an enum status and belongs_to owner (a User).
class NestedFilteringTest < ActionDispatch::IntegrationTest
  setup do
    sign_in
    @alice = create(:user, name: "Alice")
    @bob   = create(:user, name: "Bob")
    @live  = create(:client, status: :active,   owner: @alice)
    @old   = create(:client, status: :archived, owner: @bob)
    @a = create(:invoice, client: @live)
    @b = create(:invoice, client: @old)
  end

  # Invoice ids surviving a filter, sorted for a stable assertion.
  def ids(filters)
    get "/admin/invoices.json", params: filters
    assert_response :success
    response.parsed_body.map { _1["id"] }.sort
  end

  test "a nested enum filter matches records via the association's column" do
    # `?client.status=archived` → invoices whose client is archived (a join +
    # WHERE clients.status = <archived>), not just a 200.
    assert_equal [ @b.id ], ids("client.status" => "archived")
    assert_equal [ @a.id ], ids("client.status" => "active")
  end

  test "a nested belongs_to filter matches records via the far foreign key" do
    # `?client.owner_id=<alice>` → invoices whose client's owner is Alice.
    assert_equal [ @a.id ], ids("client.owner_id" => @alice.id)
    # The set form the multi-select posts (`client.owner_id[]`) still filters.
    assert_equal [ @a.id, @b.id ], ids("client.owner_id" => [ @alice.id, @bob.id ])
  end

  test "an undeclared nested path is ignored, not filtered" do
    # `client.owner.email` is a real column three hops out, but the path isn't on
    # permitted_filters. Were it honored it would filter to zero (no such email);
    # dropped before SQL, the index stays whole — proving the gate rejects the
    # full path, not just the top-level key.
    assert_equal [ @a.id, @b.id ], ids("client.owner.email" => "nobody@example.com")
  end

  test "a real far column left off the declared path is ignored" do
    # `client.name` names a real Client column, but only `client.status` /
    # `client.owner` are declared — an undeclared sibling path is dropped.
    assert_equal [ @a.id, @b.id ], ids("client.name" => "no-such-client")
  end

  test "the nested controls render in the filter panel, typed by the terminal" do
    get "/admin/invoices"
    assert_response :success
    assert_select ".Page_Aside form" do
      # nested enum -> the enum select of the far model's keys
      assert_select "select[name='client.status']", 1 do
        assert_select "option[value=active]",   text: "active"
        assert_select "option[value=archived]", text: "archived"
      end
      # nested belongs_to -> the association multi-select on the far foreign key
      assert_select "select[name='client.owner_id[]'][multiple][data-searchable-select]", 1
    end
  end

  test "an active nested filter value round-trips into its control" do
    get "/admin/invoices", params: { "client.status" => "archived" }
    assert_response :success
    assert_select ".Page_Aside form select[name='client.status'] option[selected][value=archived]", 1
  end
end
