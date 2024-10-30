module CafeCar
  class Context
    def initialize(template, prefix: nil)
      @template = template
      @prefix   = prefix
    end

    def method_missing(method, *args, **options, &block)
      Component.new(@template, [*@prefix, method], *args, **options, &block)
    end
  end
end
