module CafeCar
  class FormBuilder < ActionView::Helpers::FormBuilder
    delegate :ui, :render, :partial?, to: :@template

    def initialize(...)
      super
      @info   = {}
      @fields = {}
    end

    def h      = @template
    def policy = h.policy(@object)

    def association(method, collection: nil, **options)
      info         = info(method)
      collection ||= info.collection
      input(method, collection, :id, :name, as: :collection_select)
    end

    def field(method, **options, &block)
      @fields[method] ||= FieldBuilder.new(method:, form: self, **options, &block)
    end

    def info(method)
      @info[method] ||= FieldInfo.new(method:, object:)
    end

    def input(method, *args, as: nil, **options)
      as                  ||= info(method).input
      options[:placeholder] = info(method).placeholder unless options.key?(:placeholder)
      public_send(as, method, *args, **options)
    end

    def hint(method, **options)
      return unless (hint = info(method).hint)
      h.tag.small(hint, **options)
    end

    def error(method, **options)
      return unless (error = info(method).error)
      h.tag.span(error, **options)
    end

    def remaining_attributes = policy.editable_attributes - @info.keys

    def remaining_fields(**options, &block)
      block  ||= proc { field(_1, **options) }
      fields   = remaining_attributes.map(&block)
      h.safe_join(fields)
    end
  end
end
