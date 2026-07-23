require "test_helper"
require "cafe_car"

module CafeCar
  class PresenterTest < ActionView::TestCase
    helper CafeCar::Helpers

    setup do
      view.singleton_class.define_method(:policy) { |object| Pundit.policy!(nil, object) }
    end

    test "find" do
      assert_equal SymbolPresenter, Presenter.find(Symbol)
    end

    test "a host CafeCar::Presenter subclass wins over the shipped default" do
      assert_equal ::ArticlePresenter, Presenter.find(Article)
    end

    # Regression: a host class that merely ends in "Presenter" (a common Rails
    # name for other purposes) must not be adopted — lookup skips it, warns
    # once, and falls through to the shipped defaults.
    test "an unrelated same-named class is skipped with a single warning" do
      with_top_level(:NotePresenter, Class.new { def initialize(note); end }) do
        logs = capture_log { assert_equal ActiveRecord::BasePresenter, Presenter.find(Note) }

        assert_match %r{\[CafeCar\] NotePresenter does not inherit CafeCar::Presenter}, logs
        assert_empty capture_log { Presenter.find(Note) }, "warns once per constant, not per lookup"
      end
    end

    test "default presentation still works alongside an unrelated same-named class" do
      note = create(:note)

      with_top_level(:ClientPresenter, Class.new { def initialize(client); end }) do
        assert_match note.notable.name, view.present(note.notable).to_s
      end
    end

    private

    def with_top_level(name, klass)
      Object.const_set(name, klass)
      yield
    ensure
      Object.send(:remove_const, name)
    end

    def capture_log
      io  = StringIO.new
      old = Rails.logger
      Rails.logger = ActiveSupport::Logger.new(io)
      yield
      io.string
    ensure
      Rails.logger = old
    end
  end
end
