module CafeCar::Filter
  class FormBuilder < CafeCar[:FormBuilder]
    def self.dotted_name(method)
      define_method method do |key, *args, **opts, &block|
        super(key, *args, name: field_name(key), **opts, &block)
      end
    end

    instance_methods.grep(/_field$/).each do |method|
      dotted_name method
    end

    def clean(method) = method.to_s.sub(/[~!><]+$/, '')
    def info(method)  = super(clean(method))

    def field_name(*methods, multiple: false, index: @options[:index])
      # TODO: handle multiple/index
      ["", *methods].join(".")
    end
  end
end
