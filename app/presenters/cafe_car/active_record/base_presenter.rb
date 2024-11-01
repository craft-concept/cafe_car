module CafeCar
  module ActiveRecord
    class BasePresenter < CafeCar[:Presenter]
      def policy = @policy ||= @template.policy(object)

      def title(...) = %w[title name to_s].lazy.filter_map { object.try(_1) }.map { present(_1, ...) }.first.to_s

      def attributes(*attrs, **options, &block)
        attrs = policy.displayable_attributes if attrs.blank?
        super(*attrs, **options, &block)
      end

      def associations(*names, **options, &block)
        names = policy.displayable_associations if names.blank?
        attributes(*names, **options, &block)
      end

      def to_model = object
      def to_s     = link_to title, [self] rescue title
    end
  end
end
