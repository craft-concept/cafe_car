module CafeCar
  module ActiveRecord
    class RelationPresenter < CafeCar[:Presenter]
      def to_html
        objects = object.to_a.uniq
        objects = objects.sort_by(&:sort_key) if objects.first.respond_to?(:sort_key)
        present objects, **@options
      end
    end
  end
end
