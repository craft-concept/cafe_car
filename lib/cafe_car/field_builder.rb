module CafeCar
  class FieldBuilder
    attr_reader :form, :method, :as

    delegate :object, :info, to: :form

    def initialize(method:, form:, **options, &block)
      @method  = method
      @form    = form
      @options = options
      @block   = block
    end

    def h          = @form.h
    def html_safe? = true

    def info       = form.info(@method)
    def reflection = @reflection ||= object.association(@method)&.reflection

    def wrapper(...) = h.ui.field(...)

    def add_class(*args, opts) = {class: h.ui_class([:field, *args], *opts.delete(:class)), **opts}

    def send_to_form(to, *args, **opts, &block)
      return if @options[to] == false
      form.public_send(to, @method, *args, **add_class(*to, opts), &block)
    end

    def input(...) = send_to_form(:input, ...)
    def label(...) = send_to_form(:label, ...)
    def hint(...)  = send_to_form(:hint, ...)
    def error(...) = send_to_form(:error, ...)

    def to_s
      partial = %W[#{info.type}_field field].find { h.partial?(_1) }
      h.render(partial, field: self, **@options)
    end
  end
end
