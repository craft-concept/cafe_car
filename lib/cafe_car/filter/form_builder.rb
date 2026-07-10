module CafeCar::Filter
  class FormBuilder < CafeCar[:FormBuilder]
    # Rewrites a control's name to its bare dot-query key — `price` stays
    # `price`, operators compose as `price.min` — instead of the edit form's
    # `model[price]` nesting, so a submitted control IS a filter param
    # (Controller::Filtering treats every non-control index param as a filter).
    def self.dotted_name(method)
      define_method method do |key, *args, **opts, &block|
        super(key, *args, name: field_name(key), **opts, &block)
      end
    end

    instance_methods.grep(/_field$/).each { dotted_name _1 }

    # The select family takes (options, html_options) hash pairs positionally,
    # so the name rewrite rides in html_options (an explicit :name still wins).
    def select(method, choices = nil, options = {}, html_options = {}, &block)
      super(method, choices, options, { name: field_name(clean(method)) }.merge(html_options), &block)
    end

    def collection_select(method, collection, value_method, text_method, options = {}, html_options = {})
      # A multi-select posts a set (`author_id[]`). We name every filter control
      # explicitly, which defeats Rails' automatic `[]` suffix, so restore it here.
      name  = field_name(clean(method))
      name += "[]" if html_options[:multiple]
      super(method, collection, value_method, text_method, options,
            { name: }.merge(html_options))
    end

    def model = object.model

    def clean(method)        = method.to_s.sub(/^\W+|\W+$/, "")
    def field_name(*methods) = methods.join(".")

    # Filter fields reflect through Filter::FieldInfo (the typed filter control
    # mapping), keyed on the cleaned name so `name~` and `name` share one info.
    def info(method)
      @infos ||= {}
      @infos[clean(method)] ||= const(:FieldInfo).new(model:, method: clean(method))
    end

    # The policy's permitted_filters — the panel's enumeration source — minus
    # what the view already rendered and the types no control can express.
    def remaining_attributes
      policy.attributes.filterable.reject { info(_1).unfilterable? } - @fields.keys
    end

    def scopes = policy.permitted_scopes

    # A filter is always optional — no required-* marker on its label.
    def label(method, text = nil, **opts, &)
      opts[:class] = [ ui.class(%i[field label]), *opts[:class] ]
      super(method, *text, required: false, **opts, &)
    end

    # The typed control for one permitted filter: the `_<type>_filter` partial
    # (host-overridable per type), `_range_filter` for the min/max family, then
    # the generic `_filter` fallback.
    def filter(method, **opts)
      info    = info(method)
      partial = [ "#{info.type}_filter", ("range_filter" if info.range?), "filter" ]
                  .compact.find { @template.partial?(_1) }
      @template.render(partial, f: self, info:, **opts)
    end

    # A checkbox that turns a permitted model scope on (`?published=true`).
    def scope_toggle(scope)
      @template.render("scope_filter", f: self, scope:)
    end
  end
end
