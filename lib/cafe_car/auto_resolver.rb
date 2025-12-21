module CafeCar
  module AutoResolver
    def auto_resolve!
      Object.define_method :const_missing do |name|
        define(method)
      end
    end

    def define(name)
      case name.to_s
      when /^\w+Controller$/
        Class.new(const(:ApplicationController))
      when /^\w+Policy$/
        Class.new(const(:BasePolicy))
      end
    end
  end
end
