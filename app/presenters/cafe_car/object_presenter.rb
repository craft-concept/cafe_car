module CafeCar
  class ObjectPresenter < CafeCar[:Presenter]
    def to_html = object.to_s
  end
end
