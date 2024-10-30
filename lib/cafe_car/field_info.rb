module CafeCar
  class FieldInfo
    attr_reader :method, :object

    def initialize(method:, object:)
      @method = method
      @object = object
    end

    def i18n(key)
      I18n.t(@method, scope: [:helpers, key, i18n_key], raise: true)
    rescue I18n::MissingTranslationData => _
    end

    def i18n_key = @object.model_name.i18n_key
    def type     = @object.type_for_attribute(@method)&.type || reflection&.macro

    def errors = @object.errors[@method]
    def error  = errors.to_sentence.presence

    def placeholder = i18n(:placeholder)
    def hint        = i18n(:hint)

    def input
      case type
      when :string then :text_field
      when :text then :text_area
      when :belongs_to, :has_many then :association
      else raise "Missing information about on #{@object.model_name}##{@method} of type #{type}"
      end
    end

    def association = @object.association(@method)
    def reflection  = association&.reflection

    def collection
      association&.klass&.all
    end
  end
end
