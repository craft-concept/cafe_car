module CafeCar
  #
  class FieldInfo
    attr_reader :method, :object

    def initialize(object:, method:)
      @method = method
      @object = object
    end

    def id?         = method =~ /_ids?$/
    def value       = @object.public_send(@method)
    def model       = @object.class
    def model_name  = @object.model_name
    def associated? = reflection.present?
    def foreign_key = reflection.foreign_key
    def collection  = reflection.klass.all
    def reflection  = model.reflect_on_association(@method) || reflections_by_attribute[@method]

    def errors      = @object.errors[@method] || @object.errors[reflection.name]
    def error       = errors.to_sentence.presence
    def placeholder = i18n(:placeholder)
    def hint        = i18n(:hint)
    def label       = i18n(:label)
    def prompt      = i18n(:prompt, default: "Select #{human.downcase}...")
    def human(...)  = model.human_attribute_name(@method, ...)
    def required?   = validator?(:presence)

    def validator?(kind, **options)
      @object.validators_on(@method).any? { _1.kind == kind and _1.options >= options }
    end

    def i18n_key = model_name.i18n_key
    def i18n(key, **opts)
      I18n.t(@method, scope: [:helpers, key, i18n_key], raise: true, **opts)
    rescue I18n::MissingTranslationData
    end

    def type
      @type ||=
        reflection&.macro ||
          @object.type_for_attribute(@method)&.type ||
          raise(NoMethodError.new "Can't find method #{model_name}##{@method}", @method)
    end

    def input
      case type
      when :string   then :text_field
      when :text     then :text_area
      when :integer  then :number_field
      when :datetime then :datetime_field
      when :belongs_to, :has_many then :association
      else raise "Missing FieldInfo for #{model_name}##{@method} of type :#{type}"
      end
    end

    def input_key
      case type
      when :belongs_to then foreign_key
      when :has_many then raise "implement foreign_key_ids or w/e"
      else method
      end
    end

    @@reflections_by_attribute = {}
    def reflections_by_attribute
      @@reflections_by_attribute[model] ||=
        model.reflections.values.index_by do |r|
          case r.macro
          when :belongs_to then r.foreign_key
          when :has_many   then "#{r.name.to_s.singularize}_ids"
          else raise NoMethodError.new("Not yet implemented :#{r.macro}")
          end
        end.with_indifferent_access
    end
  end
end
