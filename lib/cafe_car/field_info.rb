module CafeCar
  #
  class FieldInfo
    attr_reader :method, :object

    def initialize(method:, object:)
      @method = method
      @object = object
    end

    def input_key
      case type
      when :belongs_to then foreign_key
      when :has_many then raise "implement foreign_key_ids or w/e"
      else method
      end
    end

    def i18n_key = @object.model_name.i18n_key
    def i18n(key)
      I18n.t(@method, scope: [:helpers, key, i18n_key], raise: true)
    rescue I18n::MissingTranslationData => _
    end

    def type
      @type ||=
        @object.type_for_attribute(@method)&.type ||
          reflection&.macro ||
          raise(NoMethodError, "Can't find method #{@object.model_name}##{@method}")
    end

    def errors = @object.errors[@method]
    def error  = errors.to_sentence.presence

    def placeholder = i18n(:placeholder)
    def hint        = i18n(:hint)

    def input
      case type
      when :string   then :text_field
      when :text     then :text_area
      when :integer  then :number_field
      when :datetime then :datetime_field
      when :belongs_to, :has_many then :association
      else raise "Missing FieldInfo for #{@object.model_name}##{@method} of type :#{type}"
      end
    end

    def foreign_key = reflection&.foreign_key
    def reflection  = @object.class.reflect_on_association(@method)
    def collection  = reflection.klass.all
  end
end
