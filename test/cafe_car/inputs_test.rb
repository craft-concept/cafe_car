require "test_helper"

module CafeCar
  module Inputs
    # Proves every field type renders a correctly-bound input through its component
    # object: the right element, the right form field name, and the type-specific
    # markup (checkbox, select options, multiple upload, nested sub-form). Each case
    # builds a real CafeCar form over a dummy-app record and inspects the HTML — an
    # effect-level assertion, not just "render didn't raise".
    class InputsTest < ActionView::TestCase
      setup { view.extend CafeCar::Helpers }

      # A CafeCar form builder bound to `record` in this test's view context.
      def form(record)
        (@forms ||= {})[record] ||=
          CafeCar::FormBuilder.new(record.model_name.param_key, record, view, {})
      end

      # Render `record`'s `method` through its resolved input component and parse it.
      def input(record, method, key: form(record).info(method).input, **opts, &block)
        html = BaseInput.build(key, form: form(record), method:, template: view, **opts, &block).to_html
        Nokogiri::HTML5.fragment(html)
      end

      # Asserts a node matching `selector` exists in the rendered fragment.
      def assert_node(doc, selector)
        assert doc.at_css(selector), "expected #{selector} in:\n#{doc}"
      end

      test "string renders a bound text input" do
        assert_node input(Client.new, :name), "input[type=text][name='client[name]']"
      end

      test "text renders a bound textarea" do
        assert_node input(Invoice.new, :note), "textarea[name='invoice[note]']"
      end

      test "integer renders a bound number input" do
        assert_node input(Invoice.new, :number), "input[type=number][name='invoice[number]']"
      end

      test "decimal renders a bound text input" do
        assert_node input(LineItem.new, :price), "input[type=text][name='line_item[price]']"
      end

      test "boolean renders a native checkbox" do
        doc = input(Invoice.new, :paid)
        assert_node doc, "input[type=checkbox][name='invoice[paid]']"
        assert_node doc, "input[type=hidden][name='invoice[paid]']" # Rails' unchecked companion
      end

      test "date renders a native date input" do
        assert_node input(Invoice.new, :issued_on), "input[type=date][name='invoice[issued_on]']"
      end

      test "datetime renders a native datetime-local input" do
        assert_node input(Article.new, :published_at),
          "input[type=datetime-local][name='article[published_at]']"
      end

      test "password renders a masked input" do
        assert_node input(User.new, :password), "input[type=password][name='user[password]']"
      end

      test "enum renders a select of its declared values" do
        doc = input(Client.new, :status)
        assert_node doc, "select[name='client[status]']"
        assert_node doc, "option[value=active]"
        assert_node doc, "option[value=archived]"
      end

      test "belongs_to renders an association select on the foreign key" do
        assert_node input(Client.new, :owner_id), "select[name='client[owner_id]']"
      end

      test "has_one_attached renders a single file input" do
        doc = input(User.new, :avatar)
        assert_node doc, "input[type=file][name='user[avatar]']"
        assert_nil doc.at_css("input[type=file][multiple]")
      end

      test "has_many_attached renders a multiple file input" do
        assert_node input(User.new, :documents), "input[type=file][name='user[documents][]'][multiple]"
      end

      test "rich_text renders a trix editor bound to the field" do
        doc = input(Article.new, :body)
        assert_node doc, "input[type=hidden][name='article[body]']"
        assert_node doc, "trix-editor"
      end

      test "nested renders a fields_for sub-form for each child" do
        invoice = Invoice.new(line_items: [ LineItem.new ])
        doc = input(invoice, :line_items) { |f| f.text_field(:description) }
        assert_node doc, "input[type=text][name='invoice[line_items_attributes][0][description]']"
      end

      test "build raises for an unknown input key" do
        error = assert_raises(ArgumentError) do
          BaseInput.build(:nope, form: form(Client.new), method: :name, template: view)
        end
        assert_match "No input component for :nope", error.message
      end
    end
  end
end
