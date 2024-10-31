module CafeCar
  class Component
    attr_reader :flags

    delegate :tag, :render, :capture, :ui_class, to: :@template

    def initialize(template, name, *args, **options, &block)
      @template = template
      @name     = name
      @flags    = args.extract! { _1.is_a? Symbol }
      @args     = args
      @options  = options
      @block    = block
    end

    def h          = @template
    def names      = @names ||= [*@name].map(&:to_s).map(&:camelize)
    def class_name = ui_class(names, *@flags)
    def context    = @context ||= Context.new(@template, prefix: names)

    def html_safe? = true

    def to_s
      partial = 'ui/' + names.join('_')
      options = flags.to_h { [_1, true] }
      options.merge! @options
      element = options.delete(:tag) || :div

      contents = h.safe_join(@args)
      contents << capture(context, &@block) if @block
      return if @block and contents.blank?

      if h.partial?(partial)
        render(partial, *@args, options:, flags:, [*@name].last => context, **options) { contents }
      else
        h.content_tag(element, class: class_name) { contents }
      end
    end
  end
end
