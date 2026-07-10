module CafeCar
  module Inputs
    # Renders one bound form input for a field.
    #
    # Each field type is a small subclass that names the form-builder helper it emits
    # through (and any per-type options). `.build` maps a field's resolved input key
    # (what `FieldInfo#input` returns) to the right subclass, so *which* input a field
    # gets stays single-sourced on the field metadata — these objects only render it.
    #
    # Styling rides the shared `ui/Input.css` (native input/select/textarea), and copy
    # (placeholder, prompt, hint) comes from the field's locale via `FieldInfo` — no
    # hardcoded strings, no styles outside components.
    class BaseInput
      # Maps a resolved input key (`FieldInfo#input`) to its component class. Kept
      # lazy so the subclass constants resolve through Zeitwerk at call time.
      def self.classes
        {
          text_field:     StringInput,
          text_area:      TextAreaInput,
          number_field:   NumberInput,
          check_box:      BooleanInput,
          date_field:     DateInput,
          datetime_field: DatetimeInput,
          password_field: PasswordInput,
          file_field:     FileInput,
          rich_text_area: RichTextInput,
          enum:           SelectInput,
          association:    AssociationInput,
          fields_for:     NestedInput
        }
      end

      def self.build(key, **, &)
        klass = classes[key] or raise ArgumentError, "No input component for #{key.inspect}"
        klass.new(**, &)
      end

      attr_reader :form, :method, :template, :args, :options

      def initialize(form:, method:, template:, args: [], **options, &block)
        @form     = form
        @method   = method
        @template = template
        @args     = args
        @options  = options
        @block    = block
      end

      def info = form.info(method)

      # The form-builder helper this input renders through. Subclasses override.
      def helper = :text_field

      # Per-type option defaults, filled only where the caller left them unset.
      def defaults = {}

      # Locale-driven copy for free-text inputs — never a hardcoded string.
      def text_hints = { placeholder: info.placeholder, autocomplete: info.autocomplete }.compact

      def render_options = defaults.merge(options)

      def to_html = form.public_send(helper, method, *args, **render_options, &@block)

      def to_s       = to_html.to_s
      def html_safe? = true
    end
  end
end
