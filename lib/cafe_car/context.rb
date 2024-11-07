module CafeCar
  class Context
    def initialize(template, prefix: nil)
      @template = template
      @prefix   = prefix
    end

    def class(name, *args, **opts) = @template.ui_class([*@prefix, *name], *args, **opts)
    def wrapper(...)               = Component.new(@template, [*@prefix], ...).wrapper(...)
    def <<(obj)                    = @template.concat(obj)

    def method_missing(method, *args, **options, &block)
      Component.new(@template, [*@prefix, method], *args, **options, &block)
    end
  end
end
