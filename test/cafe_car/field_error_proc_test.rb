require "test_helper"

module CafeCar
  # Mounting the engine must not strip Rails' `field_with_errors` wrapper from a
  # host app's own forms. The engine's field_error_proc drops the wrapper only
  # inside a CafeCar form (tracked by Helpers#capture) — a plain host form, even
  # rendered from a view that carries CafeCar's helpers, keeps Rails' markup.
  class FieldErrorProcTest < ActionView::TestCase
    setup { view.extend CafeCar::Helpers }

    def invalid_client
      Client.new.tap { _1.errors.add(:name, "is invalid") }
    end

    def field_for(record, **options)
      view.form_for(record, url: "/x", **options) { |f| f.text_field(:name) }
    end

    test "a host form keeps Rails' field_with_errors wrapper" do
      assert_includes field_for(invalid_client), "field_with_errors"
    end

    test "a CafeCar form drops the wrapper but still renders the field" do
      html = field_for(invalid_client, builder: CafeCar::FormBuilder)
      assert_not_includes html, "field_with_errors"
      assert_includes html, %(name="client[name]")
    end
  end
end
