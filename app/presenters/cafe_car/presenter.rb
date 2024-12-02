module CafeCar
  class Presenter
    attr_reader :object, :options

    delegate *%w[l t capture concat link_to partial? render safe_join tag ui], to: :@template

    def self.present(template, object, **options)
      object = object.object if object.is_a?(Presenter)
      find(object.class).new(template, object, **options)
    end

    def self.find(klass)
      candidates(klass).filter_map { CafeCar[_1] }.first or raise "Could not find presenter"
    end

    def self.candidates(klass)
      klass.ancestors.lazy.map(&:name).compact.map { "#{_1}Presenter" }
    end

    def initialize(template, object, **options)
      @template         = template
      @object           = object
      @options          = options
      @shown_attributes = {}
    end

    def model  = @object.class
    def policy = @policy ||= @template.policy(object)

    def to_s         = to_html.to_s
    def to_html      = raise NoMethodError.new("Must implement to_html on this Presenter")
    def present(...) = @template.present(...)

    def title_attribute = policy.title_attribute
    def title(...)      = show(title_attribute, ...)

    def human(attribute, **options)
      object.class.human_attribute_name(attribute, options)
    end

    def attributes(*methods, except: nil, **options, &block)
      methods -= except if except
      capture do
        methods.map do |method|
          attribute(method, **options, &block)
        end.each { concat(_1) }
      end
    end

    def attribute(method, **options, &block)
      # TODO: rescue from missing attribute errors and suggest checking the policy
      @shown_attributes[method] = true
      content                   = show(method, **options, &block).to_s
      return "" if content.blank?

      ui.field do |field|
        concat field.label(safe_join([human(method), *info_circle(method)], " "), tag: :strong)
        concat field.content(content)
      end
    end

    def info_circle(method, *args, **opts, &block)
      title = FieldInfo.new(object:, method:).hint
      return unless title
      ui.info_circle(*args, title:, **opts, &block)
    end

    def controls(**options, &block)
      render("controls", object:, options:, &block)
    end

    def value(method, ...)
      value = object.public_send(method, ...)
      model.inspection_filter.filter_param(method, value)
    end

    def show(method, **options, &block)
      p     = present(value(method, **@options), **options)
      block ? capture(p, method, options, &block) : p.to_s
    end
  end
end
