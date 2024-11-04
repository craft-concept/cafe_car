module CafeCar
  module ActiveRecord
    class RelationPresenter < CafeCar[:Presenter]
      def to_html
        object = object.to_a.uniq
        object = object.sort_by(&:sort_key) if object.first.respond_to?(:sort_key)
        present object, **@options
      end
    end
  end
end
