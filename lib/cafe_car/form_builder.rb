module CafeCar
  class FormBuilder < ActionView::Helpers::FormBuilder
    include Resolver

    delegate :ui, to: :@template

    def initialize(...)
      super
      @info   = {}
      @fields = {}
    end

    def policy    = @template.policy(@object)
    def show(...) = ui.input { @template.present(@object).show(...) }

    def association(method, collection: nil, **options)
      info = info(method)

      return show(info.input_key) if info.polymorphic? and object.persisted?
      return hidden(*info.polymorphic_methods) if info.polymorphic?

      collection              ||= info.collection
      # options[:prompt]      ||= info.prompt
      options[:include_blank] ||= info.prompt

      input(info.input_key, collection, :id, -> { @template.present(_1).title }, as: :collection_select, **options)
    end

    def hidden(*methods, **, &)
      methods.map  { input(_1, as: :hidden_field, **, &) }
             .then { @template.safe_join(_1) }
    end

    def field(method, **, &)
      @fields[method] ||= const(:FieldBuilder).new(method:, form: self, template: @template, **, &)
    end

    def label(method, text = info(method).label, required: info(method).required?, **, &)
      super(method, text, required:, **, &)
    end

    def submit(value = nil, **options)
      options[:class] ||= ui.class(:button, :primary)
      super(value, options)
    end

    def info(method)
      @info[method] ||= const(:FieldInfo).new(method:, object:)
    end

    def input(method, *args, as: nil, **options)
      info = info(method)
      as ||= info.input

      options[:placeholder] = info.placeholder unless options.key?(:placeholder)
      public_send(as, method, *args, **options)
    end

    def hint(method, text = info(method).hint, **)
      @template.tag.small(text, **) if text.present?
    end

    def error(method, text = info(method).error, **)
      @template.tag.span(text, **) if text.present?
    end

    def remaining_attributes = policy.editable_attributes - @fields.keys

    def remaining_fields(**, &block)
      block  ||= proc { field(_1, **) }
      fields   = remaining_attributes.map(&block)
      @template.safe_join(fields)
    end
  end
end
