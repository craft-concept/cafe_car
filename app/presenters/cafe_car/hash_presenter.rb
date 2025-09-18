module CafeCar
  class HashPresenter < self[:Presenter]
    def to_html = tag.code(JSON.pretty_generate(object), class: 'pretty_inspect')
  end
end
