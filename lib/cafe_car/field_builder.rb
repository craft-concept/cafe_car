module CafeCar
  class FieldBuilder
    attr_reader :form, :method, :as

    delegate :object, :info, to: :form

    def initialize(method:, form:, template:, **options, &block)
      @method   = method
      @form     = form
      @template = template
      @options  = options
      @block    = block
    end

    def html_safe?   = true
    def info         = form.info(@method)
    def wrapper(...) = @template.ui.field(...)
    def input(...)   = send_to_form(:input, ...)
    def label(...)   = send_to_form_with_text(:label, ...)
    def hint(...)    = send_to_form_with_text(:hint, ...)
    def error(...)   = send_to_form_with_text(:error, ...)

    def to_s
      partial = %W[#{info.type}_field field].find { @template.partial?(_1) }
      @template.render(partial, field: self, **@options)
    end

    private

    def add_class(*args, opts) = {class: @template.ui_class([:field, *args], *opts.delete(:class)), **opts}

    def send_to_form_with_text(method, text = @options.delete(method), **, &)
      send_to_form(method, text, **, &)
    end

    def send_to_form(to, *, **opts, &)
      return if @options[to] == false
      form.public_send(to, @method, *, **add_class(*to, opts), &)
    end
  end
end
