module CafeCar
  class FormBuilder < ActionView::Helpers::FormBuilder
    delegate :ui, :render, :partial?, to: :@template
    def h = @template

    def field_type(method) = @object.type_for_attribute(method)&.type

    def field(method, as: field_type(method), **options, &block)
      field = FieldBuilder.new(method:, ui: ui.field.context, form: self)
      render("field", f: self, method:, as:, field:, **options)
    end

    def error_for(method) = object.errors[method].presence

    def hint_for(method) =
      I18n.t(method, scope: [:helpers, :hint, @object_name]).presence

    def hint(method, **options)
      return unless (hint = hint_for method)
      h.tag.span(hint, **options)
    end

    def error(method, **options)
      return unless (errors = error_for method)
      h.tag.span(errors.to_sentence, **options)
    end
  end
end
