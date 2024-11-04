module CafeCar
  class Component
    attr_reader :flags, :options

    delegate :tag, :render, :capture, :ui_class, to: :@template

    def initialize(template, name, *args, tag: :div, **options, &block)
      @template = template
      @names    = [*name]
      @tag      = tag
      @flags    = args.extract! { _1.is_a? Symbol }
      @args     = args
      @options  = @flags.to_h { [_1, true] }.merge!(options)
      @block    = block
    end

    def name     = @names.last
    def context  = @context ||= Context.new(@template, prefix: @names)
    def partial? = @template.partial?(partial_name)

    def partial_name = 'ui/' + @names.join('_')

    def class_names     = @names.map(&:to_s).map(&:camelize)
    def class_name(...) = ui_class(class_names, *@flags, ...)

    def contents
      @contents ||= @template.safe_join([*@args, *(capture(context, &@block) if @block)])
    end

    def wrapper(*args, **opts, &block)
      @template.content_tag(@tag, *args, class: class_name(*opts.delete(:class)), **opts) do
        capture(context, &block)
      end
    end

    def html_safe? = true
    def to_s
      return "" if @block and contents.blank?

      if partial?
        render(partial_name, options:, flags:, name => context, **options) { contents }
      else
        wrapper(*@args, **@options) { contents }
      end
    end
  end
end
