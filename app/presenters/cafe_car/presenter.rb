module CafeCar
  class Presenter
    include Caching
    include OptionHelpers

    delegate *%w[l t capture concat link link_to partial? get_partial href_for render safe_join tag ui], to: :@template
    delegate :context, :context?, to: :@template
    delegate :model_name, to: :model

    attr_reader :object, :options, :block
    class_attribute :show_defaults, default: Hash.new { _1[_2] = {} }

    def self.inherited(subclass)
      super
      subclass.show_defaults = show_defaults.deep_dup
    end

    def self.present(template, object, **options, &)
      object = object.object if object.is_a?(Presenter)
      find(options.fetch(:as) { object.class }).new(template, object, **options, &)
    end

    def self.find(klass)
      candidates(klass).filter_map { CafeCar[_1] }.first or raise "Could not find presenter"
    end

    def self.candidates(klass)
      names(klass).map { "#{_1}Presenter" }
    end

    def self.names(klass)
      return [klass.to_s.classify] if klass.is_a?(Symbol)
      klass.ancestors.lazy.map(&:name).compact
    end

    def self.show(method, proc = nil, **, &block)
      block ||= proc
      show_defaults[method].merge!({block:}.compact, **)
    end

    def initialize(template, object, **options, &block)
      @template         = template
      @object           = object
      @options          = options
      @block            = options.delete(:block) { block }
      @shown_attributes = {}
      assign_options!
    end

    def to_model   = @object
    def model      = @object.is_a?(Class) ? @object : @object.class
    def html_safe? = true
    def to_s       = to_html.to_s
    def present(...) = @template.present(...)
    def partial      = @object.try(:to_partial_path)
    def has_partial? = partial&.then { partial? _1 }

    derive :policy,   -> { @template.policy(@object) }
    derive :captured, -> { @block ? capture(self, &@block) : @object.to_s }

    def to_html
      return render(object:, partial:) if has_partial?
      if context?(:a)
        preview
      else
        link_to (context(:a) { preview }), href rescue preview
      end
    end

    def title(...) = show(policy.title_attribute, ...)
    def logo(...) = show(policy.logo_attribute, ...)

    def attributes(*methods, except: nil, **options, &block)
      methods  = policy.displayable_attributes if methods.empty?
      methods  = methods.flatten.compact
      methods -= [*except]
      capture do
        methods.map do |method|
          attribute(method, **options, &block)
        end.each { concat(_1) }
      end
    end

    def links = link(object)
    def href  = href_for(object)

    def preview(**, &)
      ui.row do
        concat logo(size: :icon)
        concat title
      end
    end

    def attribute(method, **, &)
      content = show(method, &)
      return "" if content.blank?

      ui.Field do |f|
        concat f.Label(safe_join([human(method), *info_circle(method)], " "), tag: :strong)
        concat f.Content(content)
      end
    end

    def info(method) = model.info.field(method)
    def human(method, **) = model.human_attribute_name(method, **)

    def value(method)
      model.inspection_filter.filter_param(method, object.try(method))
    end

    def show(method, **, &)
      return if method.nil?
      @shown_attributes[method] = true
      present(value(method), **show_defaults[method], **, &)
    end

    def remaining_attributes(**options, &block)
      attrs = policy.displayable_attributes - @shown_attributes.keys
      attributes(*attrs, **options, &block)
    end

    def associations(*names, **options, &block)
      names = policy.displayable_associations if names.blank?
      attributes(*names, **options, &block)
    end

    def info_circle(method, *args, **opts, &block)
      title = info(method).hint
      return unless title
      ui.info_circle(*args, title:, **opts, &block)
    end

    def controls(**options, &block)
      render("controls", object:, options:, &block)
    end

    # def card(**)
    #   ui.card title:, ** do |card|
    #     ui <<
    #   end
    # end

    def i18n_vars(names) = names.merge(*names.map { {_1.to_s.downcase.to_sym => _2.downcase} })

    def i18n(action, scope: nil, **)
      vars = i18n_vars Action: t(action, default: action.to_s.humanize),
                       Model:  model_name.human,
                       Models: model_name.human(count: 2),
                       Object: link(@object).to_s.html_safe
      @template.translate(action, scope:, default: :default, deep_interpolation: true, **vars, **)
    end
  end
end
