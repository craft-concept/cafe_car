module CafeCar
  class HashPresenter < self[:Presenter]
    def to_html = tag.code(object.pretty_inspect, class: 'pretty_inspect')
  end
end
