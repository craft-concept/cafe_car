module CafeCar
  class Component
    delegate :tag, :render, :capture, :ui_class, to: :@helpers

    def initialize(helpers, name, *args, **options, &block)
      @helpers = helpers
      @name    = name
      @args    = args
      @options = options
      @block   = block
    end

    def h     = @helpers
    def names = @names ||= [*@name].map(&:to_s).map(&:camelize)

    def class_name = ui_class(names, *@args, **@options)
    def context    = @context ||= UI::Context.new(@helpers, prefix: names)

    def html_safe? = true

    def to_s
      partial = 'ui/' + names.join('_')
      options = @args.extract! { _1.is_a? Symbol }.to_h { [_1, true] }
      options.merge! @options
      element = options.delete(:tag) || :div

      h.capture(context, &@block) if @block
      contents = nil

      if h.lookup_context.template_exists?(partial, [], true)
        render(partial, *@args, options:, names.last => context, **options) { contents }
      else
        tag(element, contents, class: class_name)
      end
    end
  end
end
