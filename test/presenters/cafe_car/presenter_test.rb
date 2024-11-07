require "test_helper"
# require "presenters/cafe_car/presenter"
require "cafe_car"

module CafeCar
  class PresenterTest < ActionView::TestCase
    tests CafeCar::Presenter

    def test_find
      assert_equal SymbolPresenter, Presenter.find(:hi)
    end
  end
end
