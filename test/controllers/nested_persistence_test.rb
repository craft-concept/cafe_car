require "test_helper"

# EFFECT-level coverage for nested has_many forms. The sibling
# nested_fields_test.rb asserts the form *renders*; this asserts the form
# *persists* — the create/update/destroy round-trip that silently dropped data
# because the policy permitted `line_items:` instead of the `line_items_attributes`
# Rails' `fields_for` actually submits (and omitted `:id`/`:_destroy`).
class NestedPersistenceTest < ActionDispatch::IntegrationTest
  setup { sign_in }

  test "creating an invoice persists its nested line items" do
    client = create(:client)

    assert_difference [ "Invoice.count", "LineItem.count" ], 1 do
      post url_for(controller: "admin/invoices", action: :create), params: {
        invoice: {
          client_id: client.id,
          line_items_attributes: { "0" => { price: 12.50, quantity: 3, description: "Widget" } }
        }
      }
    end

    line_item = Invoice.last.line_items.sole
    assert_equal "Widget", line_item.description
    assert_equal 3, line_item.quantity
  end

  test "updating an invoice updates an existing nested line item" do
    invoice   = create(:invoice, line_items: [ build(:line_item, description: "Before") ])
    line_item = invoice.line_items.sole

    patch url_for(controller: "admin/invoices", action: :update, id: invoice.id), params: {
      invoice: {
        line_items_attributes: { "0" => { id: line_item.id, description: "After" } }
      }
    }

    assert_equal "After", line_item.reload.description
    assert_equal 1, invoice.reload.line_items.count, "must update in place, not spawn a phantom row"
  end

  test "submitting _destroy=1 removes an existing nested line item" do
    invoice   = create(:invoice, line_items: [ build(:line_item), build(:line_item) ])
    doomed    = invoice.line_items.first

    assert_difference "LineItem.count", -1 do
      patch url_for(controller: "admin/invoices", action: :update, id: invoice.id), params: {
        invoice: {
          line_items_attributes: { "0" => { id: doomed.id, _destroy: "1" } }
        }
      }
    end

    assert_not LineItem.exists?(doomed.id)
  end
end
