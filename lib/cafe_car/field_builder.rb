module CafeCar
  class FieldBuilder
    attr_reader :form, :ui

    def initialize(method:, ui:, form:)
      @method = method
      @ui     = ui
      @form   = form
    end

    def h = @form.h

    def wrapper(...) = @ui.wrapper(...)

    def add_class(*args, opts) = {class: h.ui_class([:field, *args], *opts.delete(:class)), **opts}

    def send_to_form(to, add, *args, **opts, &block)
      form.public_send(to, @method, *args, **add_class(*add, opts), &block)
    end

    def input(...)
      type = :text_field
      send_to_form(type, :input, ...)
    end

    def label(...) = send_to_form(:label, :label, ...)
    def hint(...)  = send_to_form(:hint, :hint, ...)
    def error(...) = send_to_form(:error, :error, ...)
  end
end
