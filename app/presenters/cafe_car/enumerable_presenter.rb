module CafeCar
  class EnumerablePresenter < self[:Presenter]
    def count            = options[:count] || object.count
    def with_count(list) = t(:list_html, list:, count:)

    def to_html
      object.map  { present(_1) }
            .then { options[:count] == object.count ? _1 : [_1, "..."] }
            .then { safe_join(_1, ", ") }
            .then { with_count _1 }
    end
  end
end
