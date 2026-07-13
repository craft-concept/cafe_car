require "test_helper"

module CafeCar
  # Proves `FormBuilder#input` renders each field type THROUGH the input-component
  # family (`Inputs::BaseInput`) — the wiring, not the components themselves. Where
  # `inputs_test.rb` calls `BaseInput.build` directly, these build a real CafeCar form
  # and go through `form.input`, the path every view actually takes (`field.input`),
  # and inspect the emitted HTML. It also pins the `hidden` passthrough: an explicit
  # `as:` the family doesn't own must still render via the underlying form helper.
  #
  # Nested (`fields_for`) and full edit-page rendering are proven live over the whole
  # request stack (with real policies) in `nested_fields_test.rb` and
  # `field_type_round_trip_test.rb`, which GET `new`/`edit` pages through this path.
  class FormBuilderTest < ActionView::TestCase
    setup do
      view.extend CafeCar::Helpers
      view.define_singleton_method(:policy) { Pundit.policy! nil, _1 }
      view.define_singleton_method(:policy_scope) { _1.all }
    end

    # A CafeCar form builder bound to `record` in this test's view context.
    def form(record)
      (@forms ||= {})[record] ||=
        CafeCar::FormBuilder.new(record.model_name.param_key, record, view, {})
    end

    # Render `record`'s `method` through `FormBuilder#input` and parse the result.
    def input(record, method, **opts, &block)
      Nokogiri::HTML5.fragment(form(record).input(method, **opts, &block).to_s)
    end

    def assert_node(doc, selector)
      assert doc.at_css(selector), "expected #{selector} in:\n#{doc}"
    end

    test "string routes to a bound text input" do
      assert_node input(Client.new, :name), "input[type=text][name='client[name]']"
    end

    test "enum routes to a bound select of its values" do
      doc = input(Client.new, :status)
      assert_node doc, "select[name='client[status]']"
      assert_node doc, "option[value=active]"
    end

    test "boolean routes to a native checkbox" do
      doc = input(Invoice.new, :paid)
      assert_node doc, "input[type=checkbox][name='invoice[paid]']"
      assert_node doc, "input[type=hidden][name='invoice[paid]']" # Rails' companion
    end

    test "association routes to a select on the foreign key" do
      assert_node input(Client.new, :owner_id), "select[name='client[owner_id]']"
    end

    test "an explicit non-component `as:` falls through to the form helper" do
      doc = Nokogiri::HTML5.fragment(form(Client.new).hidden(:name).to_s)
      assert_node doc, "input[type=hidden][name='client[name]']"
    end
  end
end
