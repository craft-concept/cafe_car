module CafeCar
  class Component
    include OptionHelpers

    concerning :Macros do
      class_methods do
        def component(*names, **, &)
          names.each do |name|
            define_class(name, const(:Component), **, &)
          end
        end
      end
    end

    attr_reader :flags, :options

    delegate :tag, :render, :capture, :safe_join, :ui_class, to: :@template

    option :tag, default: :div

    def initialize(template, name, *args, **options, &block)
      @template = template
      @names    = [*name].map(&:to_s).map(&:underscore).map(&:to_sym)
      @flags    = args.extract! { _1.is_a? Symbol }
      @args     = args.flatten.compact_blank
      @children = options.extract_if! { _1 =~ /^[A-Z]\w*$/ }
      @options  = options
      @block    = block
      options.transform!(:href) { @template.href_for _1 }
      assign_options!
    end

    def name     = @names.last
    def context  = @context ||= Context.new(@template, prefix: @names)
    def partial? = @template.partial?(partial_name)
    def href?    = options[:href].present?
    def tag_name = href? && !current_href? ? :a : @tag

    def current_href? = options[:href]&.then { @template.current_href?(_1, check_parameters: true) }
    def ancestor_href? = options[:href]&.then { @template.ancestor_href?(_1) }

    def partial_name = 'ui/' + @names.join('_')

    def class_names     = @names.map(&:to_s).map(&:camelize)
    def class_name(...) = ui_class(class_names, *@flags, *(@tag.to_s if href?), (:current if current_href?), (:ancestor if ancestor_href?), ...)

    def children
      @children.map {|name, content| send(name) { content } }
    end

    def content
      @content ||= @template.safe_join([*children, *@args, *(capture(self, &@block) if @block)])
    end

    def wrapper(*args, **opts, &)
      @template.content_tag(tag_name, safe_join([*args]), class: class_name(*opts.delete(:class)), **opts) do
        capture(self, &)
      end
    end

    def blank?
      content.blank? or !content.match?(/^.*?[^<\s]/) or content.gsub(/<!--.*?-->/, "").blank?
    end

    def +(o)  = safe_join([self, o])
    def <<(o) = @template.concat(o)

    def html_safe? = true

    def to_s = to_html

    def to_html
      return "" if @block and blank?

      if partial?
        render(partial_name, options:, flags:, c: self, component: self, name => self, **options) { content }
      else
        wrapper(*@args, **@options) { content }
      end
    end

    def child(name, ...) = Component.new(@template, [*@names, name], ...)

    def method_missing(name, ...)
      if name =~ /^[A-Z]/
        child(name, ...)
      else
        super
      end
    end
  end
end
