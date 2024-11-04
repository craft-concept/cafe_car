module CafeCar
  class FalseClassPresenter < CafeCar[:Presenter]
    def to_html = t(object)
  end
end
