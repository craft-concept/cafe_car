require "test_helper"

# STANDING REGRESSION HARNESS — one effect-level case per supported field type.
#
# The audit's #1 meta-finding: four README-advertised features shipped broken under a
# fully-green suite because the tests asserted REQUEST SHAPE (did the page render?) not
# EFFECT (did the data change?). This closes the bug *class*: every supported field type
# is submitted through the real cafe_car update path, the record is RELOADED, and the
# persisted value is asserted — so a new field type can never silently no-op again. A
# bounded index query-count check pins the N+1 class alongside it.
#
# Each case rides the shared `submit` spine, so adding a type is one `round_trip` block.
class FieldTypeRoundTripTest < ActionDispatch::IntegrationTest
  setup { @me = sign_in }

  # Declares a field-type case: submit through the update form, reload, assert the effect.
  def self.round_trip(type, &body) = test("#{type} round-trips through the update path", &body)

  # The shared spine: PATCH `params` through the resource's real update action and prove
  # it took (redirect, not a re-rendered form). Returns the record for a `.reload` assert.
  def submit(record, **params)
    patch url_for(controller: "admin/#{record.model_name.plural}", action: :update, id: record.id),
          params: { record.model_name.param_key => params }
    assert_response :redirect,
      "#{record.class} update should persist and redirect, got #{response.status} — the field did not round-trip"
    record
  end

  def upload(name) = fixture_file_upload(name, "text/plain")

  round_trip "string          → Client#name" do
    client = create(:client)
    submit client, name: "Renamed Co"
    assert_equal "Renamed Co", client.reload.name
  end

  round_trip "text            → Invoice#note" do
    invoice = create(:invoice)
    submit invoice, note: "A handwritten note"
    assert_equal "A handwritten note", invoice.reload.note
  end

  round_trip "integer         → Invoice#number" do
    invoice = create(:invoice)
    submit invoice, number: 7
    assert_equal 7, invoice.reload.number
  end

  round_trip "decimal         → LineItem#price (nested)" do
    invoice   = create(:invoice, line_items: [ build(:line_item, price: 1) ])
    line_item = invoice.line_items.first
    submit invoice, line_items_attributes: { "0" => { id: line_item.id, price: "19.99" } }
    assert_equal BigDecimal("19.99"), line_item.reload.price
  end

  round_trip "boolean         → Invoice#paid" do
    invoice = create(:invoice, paid: false)
    # Unlike a successful update (which redirects), the edit form actually renders the
    # boolean field — the render-layer path that a missing :boolean input branch 500s.
    get url_for(controller: "admin/#{invoice.model_name.plural}", action: :edit, id: invoice.id)
    assert_response :success, "edit form with a boolean field failed to render"
    # The boolean field renders a native checkbox (themed via ui/Input.css), inside a Field.
    assert_select ".Field input[type=checkbox][name=?]", "invoice[paid]", 1
    submit invoice, paid: "1"
    assert invoice.reload.paid, "boolean did not flip to true through the update path"
  end

  round_trip "enum            → Client#status" do
    client = create(:client)
    # The edit form renders the enum as a <select> of its declared values.
    get url_for(controller: "admin/clients", action: :edit, id: client.id)
    assert_response :success, "edit form with an enum field failed to render"
    assert_select ".Field select[name=?]", "client[status]" do
      assert_select "option[value=active]", 1
      assert_select "option[value=archived]", 1
    end
    submit client, status: "archived"
    assert_equal "archived", client.reload.status
  end

  round_trip "date            → Invoice#issued_on" do
    invoice = create(:invoice)
    submit invoice, issued_on: "2026-03-04"
    assert_equal Date.new(2026, 3, 4), invoice.reload.issued_on
  end

  round_trip "datetime        → Article#published_at" do
    article = create(:article)
    submit article, published_at: "2026-01-15T10:30"
    assert_equal Time.zone.parse("2026-01-15T10:30"), article.reload.published_at
  end

  round_trip "belongs_to      → Client#owner (:references)" do
    client    = create(:client)
    new_owner = create(:user)
    submit client, owner_id: new_owner.id
    assert_equal new_owner, client.reload.owner
  end

  round_trip "has_many nested → Invoice#line_items_attributes" do
    invoice = create(:invoice, line_items: [ build(:line_item, description: "Before") ])
    submit invoice, line_items_attributes: { "0" => { id: invoice.line_items.first.id, description: "After" } }
    assert_equal "After", invoice.reload.line_items.first.description
  end

  round_trip "has_one_attached  → User#avatar" do
    submit @me, avatar: upload("doc1.txt")
    assert_equal "doc1.txt", @me.reload.avatar.filename.to_s
  end

  round_trip "has_many_attached → User#documents" do
    submit @me, documents: [ upload("doc1.txt"), upload("doc2.txt") ]
    assert_equal 2, @me.reload.documents.count
  end

  round_trip "rich_text       → Article#body" do
    article = create(:article)
    submit article, body: "Hello rich text"
    assert_equal "Hello rich text", article.reload.body.to_plain_text
  end

  round_trip "password        → User#password" do
    submit @me, password: "s3cret-pass", password_confirmation: "s3cret-pass"
    assert @me.reload.authenticate("s3cret-pass"), "new password digest did not persist"
  end

  # The N+1 class the audit flagged: an index must stay query-bounded as rows grow. Each
  # row gets a DISTINCT client + owner so AR's per-request query cache can't collapse a
  # missing eager-load onto one cached query and hide the bug (see eager_loading_test).
  test "invoices index query count does not scale with row count" do
    index_queries(1) # warm one-time schema/session lookups

    small = index_queries(3)
    large = index_queries(9)

    assert_equal small, large,
      "invoices index issued #{large} queries for 9 rows vs #{small} for 3 — " \
      "a rendered association (:client / :sender) is not eager-loaded (N+1)"
  end

  private

  # Renders /admin/invoices over `count` invoices — each fully distinct — and returns the
  # SQL query count.
  def index_queries(count)
    LineItem.delete_all
    Invoice.delete_all
    count.times { create(:invoice, client: create(:client, owner: create(:user))) }

    queries = 0
    counter = ->(*, payload) { queries += 1 unless payload[:name] == "CACHE" }
    ActiveSupport::Notifications.subscribed(counter, "sql.active_record") { get "/admin/invoices" }
    queries
  end
end
