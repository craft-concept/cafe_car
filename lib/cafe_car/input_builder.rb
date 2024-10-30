module CafeCar
  class InputBuilder
    attr_reader :form, :method, :as

    delegate :object, :object_name, to: :form

    def initialize(method:, form:, **options, &block)
      @method  = method
      @form    = form
      @options = options
      @block   = block
    end

    def type
      @type ||=
        object.type_for_attribute(@method)&.type ||
          reflect_on(method)&.macro
    end

    def placeholder
      I18n.t(method, scope: [:helpers, :placeholder, object_name], raise: true).presence
    rescue I18n::MissingTranslationData => _
    end
  end
end
