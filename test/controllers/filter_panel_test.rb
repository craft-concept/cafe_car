require "test_helper"

# Effect-level coverage of the policy-driven filter panel: every index renders
# a typed control per attribute in the policy's `permitted_filters` (plus a
# toggle per `permitted_scopes` entry), and each control's `name` IS the
# dot-query param the filtering engine consumes — so submitting the form
# filters the result set with no extra plumbing.
class FilterPanelTest < ActionDispatch::IntegrationTest
  setup { @me = sign_in }

  # Runs `assert_select` assertions scoped inside the index filter panel.
  def panel(path, params = {}, &block)
    get path, params: params
    assert_response :success
    assert_select ".Page_Aside form", &block
  end

  # --- the typed controls, per field type --------------------------------------

  test "clients: string, enum, belongs_to, and datetime controls" do
    create(:client, owner: @me)

    panel "/admin/clients" do
      assert_select "input[name='name~']",         1 # string -> contains
      assert_select "select[name=status]", 1 do      # enum -> select of keys
        assert_select "option[value=active]",   text: "active"
        assert_select "option[value=archived]", text: "archived"
      end
      # belongs_to -> Tom Select typeahead on the foreign key
      assert_select "select[name=owner_id][data-searchable-select]", 1
      assert_select "select[name=owner_id][data-searchable-select-url=?]", "/admin/users/options"
      # datetime -> min/max range pair
      assert_select "input[type=date][name='created_at.min']", 1
      assert_select "input[type=date][name='created_at.max']", 1
    end
  end

  test "invoices: numeric ranges, boolean tri-state, date range, has_many typeahead" do
    create(:invoice)

    panel "/admin/invoices" do
      assert_select "input[type=number][name='number.min']", 1  # integer
      assert_select "input[type=number][name='total.max'][step=any]", 1 # decimal
      assert_select "input[type=date][name='issued_on.min']", 1 # date
      assert_select "select[name=paid]", 1 do                   # boolean
        assert_select "option[value=true]",  1
        assert_select "option[value=false]", 1
        assert_select "option[value='']",    1 # the tri-state "any"
      end
      assert_select "select[name='line_items.id']", 1           # has_many
    end
  end

  test "articles: a checkbox per permitted scope; a non-permitted scope renders none" do
    panel "/admin/articles" do
      assert_select "input[type=checkbox][name=draft][value=true]",     1
      assert_select "input[type=checkbox][name=published][value=true]", 1
      assert_select "[name=unpublished]", 0 # defined on the model, not permitted
    end
  end

  test "a non-permitted attribute renders no control" do
    # UserPolicy narrows permitted_filters to name + created_at.
    panel "/admin/users" do
      assert_select "input[name='name~']", 1
      assert_select "[name='email~']", 0
      assert_select "[name=email]",    0
    end
  end

  test "unrenderable types are skipped: polymorphic belongs_to gets no control" do
    create(:note)

    panel "/admin/notes" do
      assert_select "select[name=author_id]", 1 # the plain belongs_to renders
      assert_select "[name=notable_id]",   0
      assert_select "[name=notable_type]", 0
    end
  end

  # --- the controls' params round-trip into filtered results -------------------

  def client_names(filters)
    get "/admin/clients.json", params: filters
    assert_response :success
    response.parsed_body.map { _1["name"] }.sort
  end

  test "the enum select's param filters by enum key" do
    create(:client, name: "Live", status: :active,   owner: @me)
    create(:client, name: "Old",  status: :archived, owner: @me)

    assert_equal [ "Old" ],  client_names("status" => "archived")
    assert_equal [ "Live" ], client_names("status" => "active")
  end

  test "the association select's param filters by foreign key" do
    mine   = create(:client, name: "Mine", owner: @me)
    create(:client, name: "Theirs", owner: create(:user))

    assert_equal [ mine.name ], client_names("owner_id" => @me.id)
  end

  test "the range pair's min/max params bound the result set" do
    create(:client, name: "Ancient", owner: @me, created_at: 3.years.ago)
    create(:client, name: "Recent",  owner: @me)

    assert_equal [ "Recent" ], client_names("created_at.min" => 1.year.ago.to_date.to_s)
  end

  test "the boolean select's param filters true and false" do
    invoice = create(:invoice)
    paid    = create(:invoice, client: invoice.client)
    paid.update!(paid: true)

    get "/admin/invoices.json", params: { "paid" => "true" }
    assert_equal [ paid.id ], response.parsed_body.map { _1["id"] }

    get "/admin/invoices.json", params: { "paid" => "false" }
    assert_equal [ invoice.id ], response.parsed_body.map { _1["id"] }
  end

  test "the has_many typeahead's param filters by associated record" do
    with_item = create(:invoice)
    create(:invoice, client: with_item.client)
    item = with_item.line_items.first

    get "/admin/invoices.json", params: { "line_items.id" => item.id }
    assert_equal [ with_item.id ], response.parsed_body.map { _1["id"] }
  end

  # --- composition & round-trip -------------------------------------------------

  test "active filter values round-trip into the controls" do
    create(:client, owner: @me, status: :archived)

    panel "/admin/clients", "status" => "archived", "name~" => "acme" do
      assert_select "select[name=status] option[selected][value=archived]", 1
      assert_select "input[name='name~'][value=acme]", 1
    end
  end

  test "search, sort, and view ride along as hidden fields (not clobbered)" do
    panel "/admin/clients", q: "acme", sort: "name", view: "grid" do
      assert_select "input[type=hidden][name=q][value=acme]",    1
      assert_select "input[type=hidden][name=sort][value=name]", 1
      assert_select "input[type=hidden][name=view][value=grid]", 1
    end
  end
end
