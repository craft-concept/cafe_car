module CafeCar
  class CurrencyPresenter < CafeCar[:Presenter]
    def to_html = @template.number_to_currency(object)
  end
end
