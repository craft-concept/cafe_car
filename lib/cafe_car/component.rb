module CafeCar
  class Component
    attr_reader :flags, :options

    delegate :tag, :render, :capture, :safe_join, :ui_class, to: :@template

    def initialize(template, name, *args, tag: :div, **options, &block)
      @template = template
      @names    = [*name].map(&:to_s).map(&:underscore).map(&:to_sym)
      @tag      = tag
      @flags    = args.extract! { _1.is_a? Symbol }
      @args     = args.flatten.compact_blank
      @options  = options
      @block    = block
    end

    def name     = @names.last
    def context  = @context ||= Context.new(@template, prefix: @names)
    def partial? = @template.partial?(partial_name)
    def href?    = options[:href].present?
    def tag_name = href? ? :a : @tag

    def partial_name = 'ui/' + @names.join('_')

    def class_names     = @names.map(&:to_s).map(&:camelize)
    def class_name(...) = ui_class(class_names, *@flags, *(@tag.to_s if href?), ...)

    def content
      @content ||= @template.safe_join([*@args, *(capture(self, &@block) if @block)])
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
    def to_s
      return "" if @block and blank?

      if partial?
        render(partial_name, options:, flags:, c: self, component: self, name => self, **options) { content }
      else
        wrapper(*@args, **@options) { content }
      end
    end

    def method_missing(name, ...)
      if name =~ /^[A-Z]/
        Component.new(@template, [*@names, name], ...)
      else
        super
      end
    end
  end
end
