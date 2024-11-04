module CafeCar
  class Presenter
    attr_reader :object, :options

    delegate *%w[l t capture concat link_to render safe_join tag ui], to: :@template

    def self.present(template, object, **options)
      find(object.class).new(template, object, **options)
    end

    def self.find(klass)
      candidates(klass).filter_map { CafeCar[_1] }.first
    end

    def self.candidates(klass)
      klass.ancestors.lazy.map { "#{_1.name}Presenter" }
    end

    def initialize(template, object, **options)
      @template = template
      @object   = object
      @options  = options
    end

    def to_s         = to_html
    def to_html      = raise("to_s unimplemented on this Presenter")
    def present(...) = @template.present(...)

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
      content = show(method, **options, &block).to_s
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

    def show(method, **options, &block)
      p = present(object.public_send(method, **@options), **options)
      block ? capture(p, method, options, &block) : p.to_s
    end
  end
end
