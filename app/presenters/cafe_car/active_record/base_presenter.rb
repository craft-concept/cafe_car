module CafeCar
  module ActiveRecord
    class BasePresenter < CafeCar[:Presenter]
      def attributes(*attrs, **options, &block)
        attrs = policy.displayable_attributes if attrs.empty?
        attrs = attrs.flatten.compact
        super(*attrs, **options, &block)
      end

      def associations(*names, **options, &block)
        names = policy.displayable_associations if names.blank?
        attributes(*names, **options, &block)
      end

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
