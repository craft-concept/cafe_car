module CafeCar
  class SymbolPresenter < CafeCar[:Presenter]
    def to_html = object.to_s.humanize
  end
end
