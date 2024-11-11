module CafeCar
  class FormBuilder < ActionView::Helpers::FormBuilder
    delegate :ui, :tag, :render, :partial?, to: :@template

    def initialize(...)
      super
      @info   = {}
      @fields = {}
    end

    def h      = @template
    def policy = h.policy(@object)

    def association(method, collection: nil, **options)
      info                      = info(method)
      collection              ||= info.collection
      # options[:prompt]        ||= info.prompt
      options[:include_blank] ||= info.prompt
      input(info.input_key, collection, :id, -> { h.present(_1).title }, as: :collection_select, **options)
    end

    def field(method, **, &)
      @fields[method] ||= FieldBuilder.new(method:, form: self, **, &)
    end

    def label(method, text = info(method).label, required: info(method).required?, **, &)
      super(method, text, required:, **, &)
    end

    def info(method)
      @info[method] ||= FieldInfo.new(method:, object:)
    end

    def input(method, *args, as: nil, **options)
      info                  = info(method)
      as                  ||= info.input
      options[:placeholder] = info.placeholder unless options.key?(:placeholder)
      public_send(as, method, *args, **options)
    end

    def hint(method, **)
      return unless hint = info(method).hint
      tag.small(hint, **)
    end

    def error(method, **)
      return unless error = info(method).error
      tag.span(error, **)
    end

    def remaining_attributes = policy.editable_attributes - @info.keys

    def remaining_fields(**, &block)
      block  ||= proc { field(_1, **) }
      fields   = remaining_attributes.map(&block)
      h.safe_join(fields)
    end
  end
end
