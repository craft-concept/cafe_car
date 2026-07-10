module CafeCar
  class FormBuilder < ActionView::Helpers::FormBuilder
    include Resolver

    delegate :ui, to: :@template

    def initialize(...)
      super
      @fields = {}
    end

    def model     = @object.is_a?(Class) ? @object : @object.class
    def policy    = @template.policy(@object)
    def show(...) = ui.Input { @template.present(@object).show(...) }

    def association(method, collection: nil, multiple: false, **options)
      info = info(method)

      return show(info.input_key) if info.polymorphic? and object.persisted?
      return hidden(*info.polymorphic_methods) if info.polymorphic?

      collection ||= with_selected(info)
      # A multi-select filters by a set (`author_id[]`), so no blank "any" option —
      # an empty selection already means "any". A single select keeps its prompt.
      options[:include_blank] ||= info.prompt unless multiple

      html = searchable_select(info)
      html[:multiple] = true if multiple

      collection_select(info.input_key, collection, :id,
                        -> { @template.present(_1).title }, options, html)
    end

    # HTML options that flag an association <select> for Tom Select enhancement
    # (see cafe_car.js). When the associated model exposes an `options` typeahead
    # feed, its URL rides along so keystroke search can reach records past
    # `max_collection_options`; without it the field degrades to a plain select.
    def searchable_select(info)
      data = { "searchable-select": "" }
      url  = options_url(info.reflection&.klass)
      data["searchable-select-url"] = url if url
      { data: }
    end

    # URL of the associated model's typeahead feed in the current namespace, or nil
    # when no such route exists. e.g. `belongs_to :owner` -> `options_admin_users_path`.
    def options_url(klass)
      return unless klass
      helper = [ :options, *@template.namespace, klass.model_name.route_key, :path ].join("_")
      @template.public_send(helper) if @template.respond_to?(helper)
    end

    # The capped option collection, guaranteeing the currently-associated record is
    # among the options even when it sorts past the cap — otherwise editing a record
    # whose association is beyond `max_collection_options` would silently drop the value.
    def with_selected(info)
      collection = info.collection
      return collection unless info.reflection&.belongs_to?

      selected = object.try(info.reflection.name)
      return collection unless selected

      records = collection.to_a
      records.include?(selected) ? records : [ selected, *records ]
    end

    # An ActiveRecord enum renders as a plain <select> of its declared values,
    # read straight off `defined_enums` (see FieldInfo#values).
    def enum(method, choices = nil, **options)
      info = info(method)

      choices                 ||= info.values
      options[:include_blank] ||= info.prompt

      select(method, choices, options)
    end

    def hidden(*methods, **, &)
      methods.map  { input(_1, as: :hidden_field, **, &) }
             .then { @template.safe_join(_1) }
    end

    def field(method, **, &)
      @fields[method] ||= const(:FieldBuilder).new(method:, form: self, template: @template, **, &)
    end

    def label(method, text = info(method).label, required: info(method).required?, **, &)
      super(method, @template.safe_join([ text, required ? "*" : "" ]), required:, **, &)
    end

    def submit(value = nil, **options)
      options[:class] ||= ui.class(:button, :primary)
      super(value, options)
    end

    def info(method) = model.info.field(method)

    def input(method, *args, as: nil, **options)
      info = info(method)
      as ||= info.input

      options[:placeholder]  = info.placeholder  unless options.key?(:placeholder)
      options[:autocomplete] = info.autocomplete unless options.key?(:autocomplete)
      options[:multiple]     = true if as == :file_field && info.multiple? && !options.key?(:multiple)

      # Field-typed inputs render through their component object; explicit `as:`
      # overrides the family doesn't own (e.g. `hidden_field`) fall through to the
      # helper directly, preserving `#input`'s "render via any form helper" contract.
      return public_send(as, method, *args, **options) unless Inputs::BaseInput.classes.key?(as)

      Inputs::BaseInput.build(as, form: self, method:, template: @template, args:, **options).to_html
    end

    def hint(method, text = info(method).hint, **)
      @template.tag.small(text, **) if text.present?
    end

    def errors(method)
      errors     = object.try(:errors)
      associated = info(method).reflection&.then { errors[_1.name] } || []
      errors[method] | associated
    end

    def error_text(method)
      errors(method).to_sentence.presence
    end

    def error(method, text = error_text(method), **)
      @template.tag.span(text, **) if text.present?
    end

    def fields_for(method, object = object_for(method), **, &)
      method = method.to_s.chomp("_attributes").to_sym
      if block_given?
        super
      else
        super(method, **) do |f|
          f.remaining_fields
        end
      end
    end

    def object_for(method)
      method = method.to_s.chomp("_attributes").to_sym
      if info(method).reflection.collection?
        object.try(method)
      else
        object.try(method) || object.try("build_#{method}")
      end
    end

    def remaining_attributes = policy.attributes.editable - @fields.keys

    def remaining_fields(**, &block)
      block  ||= proc { field(_1, **) }
      fields   = remaining_attributes.map(&block)
      @template.safe_join(fields)
    end
  end
end
