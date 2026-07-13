require "test_helper"
require "minitest/mock"

class AssociationAuthorizationTest < ActionDispatch::IntegrationTest
  setup { sign_in }

  test "a polymorphic target outside its policy scope cannot be assigned" do
    visible = create(:client)
    hidden  = create(:client)

    with_scope(ClientPolicy::Scope, Client.where(id: visible.id)) do
      assert_no_difference "Note.count" do
        post "/admin/notes", params: {
          note: { body: "Private", notable_type: "Client", notable_id: hidden.id }
        }
      end
    end

    assert_response :redirect
  end

  test "an invalid polymorphic type is denied instead of raising" do
    assert_no_difference "Note.count" do
      post "/admin/notes", params: {
        note: { body: "Private", notable_type: "MissingModel", notable_id: "1" }
      }
    end

    assert_response :redirect
  end

  test "an association nested inside permitted attributes is policy-scoped" do
    invoice = create(:invoice, line_items: [ build(:line_item) ])
    hidden  = create(:invoice)
    item    = invoice.line_items.sole

    with_permitted_line_item_invoice do
      with_scope(InvoicePolicy::Scope, Invoice.where(id: invoice.id)) do
        patch "/admin/invoices/#{invoice.id}", params: {
          invoice: {
            line_items_attributes: {
              "0" => { id: item.id, invoice_id: hidden.id, description: item.description }
            }
          }
        }
      end
    end

    assert_response :redirect
    assert_equal invoice, item.reload.invoice
  end

  private

  def with_scope(scope_class, relation)
    resolved = Struct.new(:relation) { def resolve = relation }
    scope_class.stub(:new, ->(_user, _scope) { resolved.new(relation) }) { yield }
  end

  def with_permitted_line_item_invoice
    original = LineItemPolicy.instance_method(:permitted_attributes)
    LineItemPolicy.define_method(:permitted_attributes) do
      [ *original.bind_call(self), :invoice_id ]
    end
    yield
  ensure
    LineItemPolicy.define_method(:permitted_attributes, original)
  end
end
