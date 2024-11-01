module CafeCar
  class SymbolPresenter < CafeCar[:Presenter]
    def to_s = object.to_s.humanize
  end
end
