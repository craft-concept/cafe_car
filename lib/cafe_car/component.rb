module CafeCar
  class Component
    concerning :Macros do
      included do
        class_attribute :option_defaults, default: {}
        class_attribute :attribute_defaults, default: {}
      end

      def extract_options!(options)
        @options = options.extract!(*option_defaults.keys).with_defaults!(option_defaults)
      end

      class_methods do
        def inherited(subclass)
          super
          subclass.option_defaults = option_defaults.deep_dup
          subclass.attribute_defaults = attribute_defaults.deep_dup
        end

        def component(*names, **, &)
          names.each do |name|
            define_class(name, CafeCar[:Component], **, &)
          end
        end

        def flag(flag)
          include Module.new do
            define_method(flag) { |v| @options[flag] = v.nil? ? true : v }
          end
        end

        def option(name, default: nil, accessor: true, reader: accessor, writer: accessor, presence: accessor, macro: accessor)
          option_defaults[name] = default
          define_singleton_method(name) { |v| option_defaults[name] = v } if macro
          include Module.new {
            define_method(name) { options[name] } if reader
            define_method("#{name}=") { |v| options[name] = v } if writer
            define_method("#{name}?") { options[name].present? } if presence
          }
        end
      end
    end

    def self.method_missing(name, v)
      attribute_defaults[name] = v
    end

    attr_reader :flags, :options, :attributes

    delegate :render, :capture, :safe_join, :ui_class, :context?, to: :@template

    option :tag, default: :div
    option :class, accessor: false
    option :data, default: {}
    option :href
    option :tip

    def initialize(template, name, *args, **attributes, &block)
      @template   = template
      @names      = [ *name ].map(&:underscore)
      @flags      = args.extract! { _1.is_a? Symbol }
      @args       = args.flatten.compact_blank
      @attributes = attributes.with_defaults!(attribute_defaults)
      @children   = attributes.extract_if! { _1 =~ /^[A-Z]\w*$/ }
      @block      = block
      extract_options!(@attributes)
    end

    def name     = @names.last
    def tag      = href? ? :a : super
    def href?    = super && !context?(:a) && !current_href?

    def href
      @template.href_for(super) if href?
    end

    def current_href? = options[:href]&.then { @template.current_href?(_1, check_parameters: true) }
    def ancestor_href? = options[:href]&.then { @template.ancestor_href?(_1) }

    def data
      super.merge({ tip: }.compact_blank)
    end

    def partial?     = @template.partial?(partial_name)
    def partial_name = "ui/" + @names.join("_")

    def render_partial
      render(partial_name, options:, flags:, name => self, **options) { content }
    end

    def selector = class_names.join(?_).then { ?. + _1 }

    def class_names = @names.map(&:camelize)

    def class_name
      @template.ui_class(class_names, *flags, *options[:class], options[:tag].to_s => href?,
                                                        current: current_href?,
                                                        ancestor: ancestor_href? && !current_href?)
    end

    def attributes
      @attributes.merge(class: class_name, href:, data:)
    end

    def children
      @children.map { |name, content| send(name) { content } }
    end

    def blank?
      @block and body and content.blank? || !content.match?(/^.*?[^<\s]/) || content.gsub(/<!--.*?-->/, "").blank?
    end

    def body
      @body ||= context { partial? ? render_partial : content }
    end

    def content
      @content ||= safe_join [ *children, *@args, *(capture(self, &@block) if @block) ]
    end

    def context(&)
      href? ? @template.context(:a, &) : capture(&)
    end

    def wrapper(&)
      @template.content_tag(tag, **attributes, &)
    end

    def ~@    = @template.concat(self)
    def +(o)  = safe_join([ self, o ])
    def <<(o) = @template.concat(o)

    def html_safe? = true

    def to_s = to_html

    def to_html
      return "" if blank?
      wrapper { body }
    end

    def child(name, ...)
      c = self.class.try { const_defined?(name) ? const_get(name) : Component }
      c.new(@template, [ *@names, name ], ...)
    end

    def method_missing(name, ...)
      if name =~ /^[A-Z]/
        child(name, ...)
      else
        super
      end
    end
  end
end
