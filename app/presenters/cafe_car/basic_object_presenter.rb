module CafeCar
  class BasicObjectPresenter < CafeCar[:Presenter]
    def to_html = captured.presence || options[:blank]
  end
end
