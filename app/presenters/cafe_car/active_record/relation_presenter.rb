module CafeCar
  module ActiveRecord
    class RelationPresenter < CafeCar[:Presenter]
      def human(attribute, **options)
        object.human_attribute_name(attribute, options)
      end

      def each = object.each { yield present(_1) }

      def to_html
        objects = object.to_a.uniq
        objects = objects.sort_by(&:sort_key) if objects.first.respond_to?(:sort_key)
        present objects, count: object.count, **@options
      end
    end
  end
end
