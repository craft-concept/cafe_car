require "application_system_test_case"

class JavascriptFlowsTest < ApplicationSystemTestCase
  setup { @user = sign_in_browser }

  test "nested rows can be added and removed" do
    invoice = create(:invoice, line_items: [ build(:line_item) ])

    visit edit_admin_invoice_path(invoice)

    initial_count = all("[data-nested-container] [data-nested-item]").size
    assert_operator initial_count, :>, 0

    find("[data-nested-add]").click
    assert_selector "[data-nested-container] [data-nested-item]", count: initial_count + 1
    assert_no_field name: /CAFE_CAR_NEW_RECORD/

    all("[data-nested-container] [data-nested-remove]").last.click
    assert_selector "[data-nested-container] [data-nested-item]", count: initial_count

    all("[data-nested-container] [data-nested-remove]").first.click
    assert_selector "[data-nested-container] [data-nested-item]", count: initial_count - 1
    assert_field name: /\[_destroy\]/, with: "1", type: :hidden
  end

  test "bulk selection keeps its action bar and select-all state in sync" do
    create_list(:article, 2, :draft)

    visit admin_articles_path

    assert_no_selector "[data-bulk-bar]"

    boxes = all("input[name='ids[]']")
    page.execute_script("arguments[0].click()", boxes.first)
    assert_predicate boxes.first, :checked?
    assert_selector "[data-bulk-bar]"
    assert bulk_select_all_state(:indeterminate)

    page.execute_script("arguments[0].click()", find("[data-bulk-select-all]", visible: :all))
    assert all("input[name='ids[]']").all?(&:checked?)
    assert find("[data-bulk-select-all]", visible: :all).checked?
    refute bulk_select_all_state(:indeterminate)

    page.execute_script("arguments[0].click()", find("[data-bulk-select-all]", visible: :all))
    assert all("input[name='ids[]']").none?(&:checked?)
    assert_no_selector "[data-bulk-bar]"
  end

  test "a searchable association select loads and chooses a remote option" do
    target = create(:user, name: "Zephyr Owner")
    client = create(:client, owner: @user)

    with_max_collection_options(1) do
      visit edit_admin_client_path(client)

      select = find("select[name='client[owner_id]']", visible: :all)
      assert_no_selector "option[value='#{target.id}']", visible: :all
      assert_selector ".ts-wrapper"

      input = find("#client_owner_id-ts-control", visible: :all)
      page.execute_script(<<~JS, input)
        arguments[0].value = "Zephyr"
        arguments[0].dispatchEvent(new Event("input", { bubbles: true }))
      JS
      assert_selector ".ts-dropdown .option", text: "Zephyr Owner"
      page.execute_script(<<~JS, input)
        arguments[0].dispatchEvent(new KeyboardEvent("keydown", {
          bubbles: true, key: "Enter", keyCode: 13, which: 13
        }))
      JS

      assert_selector "select[name='client[owner_id]'] option[value='#{target.id}']:checked", visible: :all
      assert_equal target.id.to_s, select.value
    end
  end

  private

  def bulk_select_all_state(property)
    page.evaluate_script("document.querySelector('[data-bulk-select-all]').#{property}")
  end

  def with_max_collection_options(value)
    previous = CafeCar.max_collection_options
    CafeCar.max_collection_options = value
    yield
  ensure
    CafeCar.max_collection_options = previous
  end
end
