module CafeCar
  class HashPresenter < self[:Presenter]
    def to_s
      tag.code(object.pretty_inspect, class: 'pretty_inspect')
    end
  end
end
