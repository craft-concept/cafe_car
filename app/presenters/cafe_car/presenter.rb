module CafeCar
  class Presenter
    attr_reader :object, :options

    delegate *%w[l t capture concat link link_to partial? href_for render safe_join tag ui], to: :@template
    delegate :show_defaults, to: :class

    def self.present(template, object, **options)
      object = object.object if object.is_a?(Presenter)
      find(options.fetch(:as) { object.class }).new(template, object, **options)
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

    def self.show(method, **options, &block)
      show_defaults(method).merge!(options, block:)
    end

    def self.show_defaults(method)
      @show         ||= {}
      @show[method] ||= {}
    end

    def initialize(template, object, **options)
      @template         = template
      @object           = object
      @options          = options
      @shown_attributes = {}
    end

    def to_model = @object
    def model    = @object.class
    def policy   = @policy ||= @template.policy(object)

    def html_safe? = true
    def to_s         = to_html.to_s
    def present(...) = @template.present(...)

    def to_html
      return render object if object.try(:to_partial_path)&.then { partial? _1 }
      link_to title, href_for(self) rescue title
    end

    def title_attribute = policy.title_attribute
    def title(...)      = show(title_attribute, ...)

    def human(attribute, **options)
      object.class.human_attribute_name(attribute, options)
    end

    def attributes(*methods, except: nil, **options, &block)
      methods  = policy.displayable_attributes if methods.empty?
      methods  = methods.flatten.compact
      methods -= except if except
      capture do
        methods.map do |method|
          attribute(method, **options, &block)
        end.each { concat(_1) }
      end
    end

    def attribute(method, **options, &block)
      # TODO: rescue from missing attribute errors and suggest checking the policy
      content                   = show(method, **options, &block).to_s
      return "" if content.blank?

      ui.field do |field|
        concat field.label(safe_join([human(method), *info_circle(method)], " "), tag: :strong)
        concat field.content(content)
      end
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
      title = FieldInfo.new(object:, method:).hint
      return unless title
      ui.info_circle(*args, title:, **opts, &block)
    end

    def controls(**options, &block)
      render("controls", object:, options:, &block)
    end

    def links = link(object)

    def value(method, ...)
      value = object.public_send(method, ...)
      model.inspection_filter.filter_param(method, value)
    end

    def show(method, **options, &block)
      @shown_attributes[method] = true
      show_defaults(method)&.then { options.with_defaults!(_1) }

      block ||= options.delete(:block)

      p = present(value(method, **@options), **options)
      block ? capture(p, method, options, &block) : p
    end
  end
end
