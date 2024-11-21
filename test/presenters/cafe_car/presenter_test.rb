require "test_helper"
require "cafe_car"

module CafeCar
  class PresenterTest < ActionView::TestCase
    test "find" do
      assert_equal SymbolPresenter, Presenter.find(Symbol)
    end
  end
end
