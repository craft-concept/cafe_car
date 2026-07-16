require "test_helper"

module CafeCar
  # The safe, standalone formatting subset a host app can expose app-wide. It
  # must format values through the presenters WITHOUT dragging in CafeCar::Helpers'
  # global overrides (link_to / capture / method_missing / `p`), which are only
  # safe inside CafeCar's own admin views.
  class FormattingTest < ActionView::TestCase
    test "Presenter.present formats scalar values with no helper module mixed in" do
      # `view` here is a plain ActionView::Base — no CafeCar helpers extended.
      assert_equal number_to_currency(1234),
        CafeCar::Presenter.present(view, 1234, as: :currency).to_s
      assert_equal I18n.l(Date.new(2026, 7, 16), format: :long),
        CafeCar::Presenter.present(view, Date.new(2026, 7, 16), as: :date).to_s
    end

    test "the Formatting helper adds `present` without the admin overrides" do
      view.extend CafeCar::Formatting

      assert_equal number_to_currency(9), view.present(9, as: :currency).to_s

      # None of Helpers' footguns ride along on Formatting:
      refute_includes CafeCar::Formatting.instance_methods, :p
      refute_includes CafeCar::Formatting.instance_methods, :link_to
      refute_includes CafeCar::Formatting.instance_methods, :capture
      refute_includes CafeCar::Formatting.instance_methods, :method_missing

      # A typo'd Capitalized call is a NoMethodError, not a silent `<div class='Foo'>`.
      assert_raises(NoMethodError) { view.Frobnicate }
    end

    test "Helpers still carries the admin overrides (admin path unchanged)" do
      %i[present p link_to capture method_missing].each do |m|
        assert_includes CafeCar::Helpers.instance_methods, m
      end
    end
  end
end
