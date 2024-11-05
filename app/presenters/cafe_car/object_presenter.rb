module CafeCar
  class ObjectPresenter < CafeCar[:Presenter]
    def to_html = @template.h(object.to_s)
  end
end
