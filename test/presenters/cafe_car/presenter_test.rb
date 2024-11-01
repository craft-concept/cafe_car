require "test_helper"
require "presenters/cafe_car/presenter"

module CafeCar
  class PresenterTest < ActionView::TestCase
    tests Presenter

    def test_find
      assert_equal SymbolPresenter, Presenter.find(:hi)
    end
  end
end
