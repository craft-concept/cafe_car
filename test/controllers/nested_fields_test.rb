require "test_helper"

# End-to-end coverage for nested-attributes form rendering. Invoice
# `accepts_nested_attributes_for :line_items, allow_destroy: true`, so its
# form should render repeatable nested fields with the add-template and the
# `_destroy` plumbing. Also asserts a sibling belongs_to still renders a plain
# select, proving the type-resolution reorder didn't regress associations.
class NestedFieldsTest < ActionDispatch::IntegrationTest
  setup { sign_in }

  test "new invoice form renders nested line-item fields with an add template" do
    get url_for(controller: "admin/invoices", action: :new)

    assert_response :success
    assert_select "[data-nested-wrapper]"
    assert_select "[data-nested-container]"
    assert_select "template[data-nested-template]"
    assert_select "[data-nested-add]"
    # The <template> carries the placeholder index the JS swaps per add.
    assert_match "CAFE_CAR_NEW_RECORD", response.body
  end

  test "new invoice form still renders the belongs_to client as a select" do
    get url_for(controller: "admin/invoices", action: :new)

    assert_response :success
    assert_select "select[name=?]", "invoice[client_id]"
  end

  test "edit invoice form renders existing line items with _destroy handling" do
    invoice = create(:invoice)

    get url_for(controller: "admin/invoices", action: :edit, id: invoice.id)

    assert_response :success
    assert_select "[data-nested-item]"
    assert_select "[data-nested-remove]"
    # allow_destroy: true -> each persisted row carries a _destroy field the
    # remove button flips to "1".
    assert_select "input[name*=?]", "[_destroy]"
  end
end
