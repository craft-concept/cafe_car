module CafeCar
  class FilterFormBuilder < CafeCar[:FormBuilder]
    def self.fix_name(method)
      define_method method do |key, *args, **opts, &block|
        super(key, *args, name: field_name(key), **opts, &block)
      end
    end

    fix_name :text_field

    def field_name(*methods, multiple: false, index: @options[:index])
      # TODO: handle multiple/index
      ["", *methods].join(".")
    end

    def info(method)
      super(method.to_s.sub(/[~!><]$/, ''))
    end
  end
end
