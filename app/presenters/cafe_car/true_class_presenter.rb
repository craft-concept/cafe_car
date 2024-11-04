module CafeCar
  class TrueClassPresenter < CafeCar[:Presenter]
    def to_html = t(object)
  end
end
