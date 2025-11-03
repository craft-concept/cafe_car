module CafeCar
  class Context
    def initialize(template, prefix: nil)
      @template = template
      @prefix   = prefix
    end

    def class(name, ...) = @template.ui_class([*@prefix, *name], ...)
    def wrapper(...)     = Component.new(@template, [*@prefix], ...).wrapper(...)
    def <<(obj)          = @template.concat(obj)

    def method_missing(method, ...)
      Component.new(@template, [*@prefix, method], ...)
    end
  end
end
