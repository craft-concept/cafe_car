module CafeCar
  module OptionHelpers
    extend ActiveSupport::Concern

    included do
      class_attribute :option_defaults, default: {}
    end

    def assign_options!
      raise "@options is not a hash" unless @options
      option_defaults.each { assign_option!(_1, _2) }
    end

    def assign_option!(k, default)
      value = @options.delete(k) { default.respond_to?(:call) ? default.call : default.clone }
      instance_variable_set("@#{k}", value)
    end

    class_methods do
      def inherited(subclass)
        super
        subclass.option_defaults = option_defaults.deep_dup
      end

      def option(name, default: nil, accessor: true, reader: accessor, writer: accessor)
        attr_reader name if reader
        attr_writer name if writer
        option_defaults[name] = default
        define_method("#{name}?") { instance_variable_get("@#{name}").present? }
      end

      def option_accessor(name)
        define_method(name) { @options[name] }
        define_method("#{name}=") { @options[name] = _1 }
      end
    end
  end
end
