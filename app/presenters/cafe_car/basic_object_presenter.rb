module CafeCar
  class BasicObjectPresenter < CafeCar[:Presenter]
    def to_html = object.to_s
  end
end
