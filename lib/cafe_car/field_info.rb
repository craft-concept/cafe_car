module CafeCar
  class FieldInfo
    attr_reader :method, :model
    alias_method :name, :method

    delegate :model_name, to: :@model

    def initialize(model:, method:)
      @method = method.to_sym
      @model = model
    end

    def info(method) = model.info.field(method)

    def id?          = method =~ /_ids?$/
    def constant?    = method.in? %i[id created_at updated_at]
    def association? = model.reflect_on_association(@method).present?
    def associated?  = reflection.present?
    def polymorphic? = reflection&.polymorphic?
    def digest?      = method =~ /_digest$/
    def password?    = type == :password
    def rich_text?   = reflection&.name =~ /^rich_text_(\w+)$/
    def attachment?  = model.reflect_on_attachment(method)
    def collection   = reflection.klass.all
    def reflection   = model.reflect_on_association(@method) || reflections_by_attribute[@method]

    def abrogated_keys
      [*reflection&.foreign_type&.to_sym]
    end

    def displayable = reflection&.name&.then { info(_1) } || self

    def default_type
      case method
      when :controls then method
      end
    end

    def reflection_type = reflection&.macro
    def attribute_type  = model.type_for_attribute(@method)&.type
    def digest_type
      if @method =~ /^(\w+)(_confirmation)?$/
        model.type_for_attribute("#{$1}_digest")&.type && :password
      end
    end

    def attachment_type
      :attachment if attachment?
    end

    def polymorphic_methods = [reflection.foreign_type, reflection.foreign_key]

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
      @type ||= reflection_type || attribute_type || digest_type || attachment_type || default_type ||
        raise(NoMethodError.new "Can't find attribute :#{@method} on #{model_name}", @method)
    end

    def width
      case type
      when :text, :string, :json
        # "minmax(10em, fit-content)"
        # "minmax(10em, 1fr)"
        "minmax(10em, auto)"
        # "min-content"
      else "min-content"
      end
    end

    def input
      case type
      when :string   then :text_field
      when :decimal  then :text_field
      when :text, :json then :text_area
      when :integer  then :number_field
      when :date     then :date_field
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
