module CafeCar
  module Resolver
    extend ActiveSupport::Concern

    def const(name)  = self.class.const(name)
    def const!(name) = self.class.const!(name)

    class_methods do
      def const_scopes = [self, *module_parents]

      def [](const_name) = const(const_name)

      def const(name)
        const_scopes.detect { _1.const_defined?(name) }
                    &.then { _1.const_get(name) }
      end

      def const!(name)
        const(name) or raise NameError, "uninitialized constant #{name}"
      end
    end
  end
end
