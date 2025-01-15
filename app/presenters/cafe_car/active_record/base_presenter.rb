module CafeCar
  module ActiveRecord
    class BasePresenter < CafeCar[:Presenter]
      def attributes(*attrs, **options, &block)
        attrs = policy.displayable_attributes if attrs.empty?
        super(*attrs, **options, &block)
      end

      def remaining_attributes(**options, &block)
        attrs = policy.displayable_attributes - @shown_attributes.keys
        attributes(*attrs, **options, &block)
      end

      def associations(*names, **options, &block)
        names = policy.displayable_associations if names.blank?
        attributes(*names, **options, &block)
      end

      def to_model = object
      def to_html
        if partial? object.to_partial_path
          render object
        else
          link_to title, href_for(self) rescue title
        end
      end
    end
  end
end
