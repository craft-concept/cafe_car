module CafeCar
  class FieldInfo
    attr_reader :method, :object

    def initialize(object:, method:)
      @method = method.to_sym
      @object = object
    end

    def info(method) = self.class.new(object:, method:)

    def id?         = method =~ /_ids?$/
    def constant?   = method.in? %i[id created_at updated_at]
    def value       = @object.public_send(@method)
    def model       = @object.try(:klass) || (@object.is_a?(Class) ? @object : @object.class)
    def model_name  = @object.model_name
    def associated? = reflection.present?
    def digest?     = method =~ /_digest$/
    def password?   = type == :password
    def rich_text?  = reflection&.name =~ /^rich_text_(\w+)$/
    def collection  = reflection.klass.all
    def reflection  = model.reflect_on_association(@method) || reflections_by_attribute[@method]

    def displayable = reflection&.name&.then { info(_1) } || self

    def reflection_type = reflection&.macro
    def attribute_type  = model.type_for_attribute(@method)&.type
    def digest_type
      if @method =~ /^(\w+)(_confirmation)?$/
        model.type_for_attribute(@method) && :password
      end
    end

    def errors      = @object.errors[@method] || @object.errors[reflection.name]
    def error       = errors.to_sentence.presence
    def placeholder = i18n(:placeholder)
    def hint        = i18n(:hint)
    def label       = i18n(:label, default: human)
    def prompt      = i18n(:prompt, default: "Select #{human.downcase}...")
    def human(...)  = model.human_attribute_name(@method, ...)
    def required?   = validator?(:presence)

    def validator?(kind, **options)
      model.validators_on(@method).any? { _1.kind == kind and _1.options >= options }
    end

    def i18n_key = model_name.i18n_key
    def i18n(key, **opts)
      I18n.t(@method, scope: [:helpers, key, i18n_key], raise: true, **opts)
    rescue I18n::MissingTranslationData
    end

    def type
      @type ||= reflection_type || attribute_type || digest_type ||
        raise(NoMethodError.new "Can't find attribute :#{@method} on #{model_name}", @method)
    end

    def input
      case type
      when :string   then :text_field
      when :text     then :text_area
      when :integer  then :number_field
      when :datetime then :datetime_field
      when :password then :password_field
      when :belongs_to, :has_many then :association
      when :has_one
        rich_text? ? :rich_text_area : nil
      else raise "Missing input type for #{model_name}##{@method} of type :#{type}"
      end
    end

    def input_key
      case type
      when :belongs_to then reflection.foreign_key
      when :has_many then raise "implement foreign_key_ids or w/e"
      else method
      end
    end

    @@reflections_by_attribute = {}
    def reflections_by_attribute
      @@reflections_by_attribute[model] ||=
        model.reflections.values.index_by do |r|
          case [r.macro, r.name]
          in [:belongs_to, *]                then r.foreign_key
          in [:has_many, *]                  then "#{r.name.to_s.singularize}_ids"
          in [:has_one, /^rich_text_(\w+)$/] then $1
          in [:has_one, *]                   then r.name
          else raise NoMethodError.new("Not yet implemented :#{r.macro}")
          end
        end.with_indifferent_access
    end
  end
end
