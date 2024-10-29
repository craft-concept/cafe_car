module CafeCar
  module UI
    class Context
      def initialize(view_context, prefix: nil)
        @view_context = view_context
        @prefix       = prefix
      end

      def method_missing(method, *args, **options, &block)
        Component.new(@view_context, [*@prefix, method], *args, **options, &block)
      end
    end
  end
end
