require "test_helper"

module CafeCar
  # Exercises the advertised `present(obj)` -> HTML path directly. The presenter
  # turns a record's policy-`displayable_attributes` into markup; these assert
  # the rendered HTML for a known dummy model rather than going through a
  # controller render.
  class RecordPresenterTest < ActionView::TestCase
    helper CafeCar::Helpers

    setup do
      ::ActiveStorage::Current.url_options = { host: "http://example.com" }
      # The presenter asks the template for a Pundit policy; the dummy's
      # ApplicationPolicy grants everything, so a nil user is fine here.
      view.singleton_class.define_method(:policy) { |object| Pundit.policy!(nil, object) }
    end

    test "title renders the title attribute" do
      client = create(:client, name: "Acme Co")

      assert_equal "Acme Co", view.present(client).title.to_s
    end

    test "attribute renders a labeled field" do
      client = create(:client, name: "Acme Co")

      html = view.present(client).attribute(:name).to_s

      assert_match %r{<strong class="Field_Label">Name</strong>}, html
      assert_match %r{<div class="Field_Content">Acme Co</div>}, html
    end

    test "attributes renders the requested displayable attributes" do
      client = create(:client, name: "Acme Co")

      html = view.present(client).attributes(:name).to_s

      assert_match %r{class="Field"}, html
      assert_match "Acme Co", html
    end

    test "to_html renders the record preview" do
      client = create(:client, name: "Acme Co")

      assert_match "Acme Co", view.present(client).to_html.to_s
    end
  end
end
