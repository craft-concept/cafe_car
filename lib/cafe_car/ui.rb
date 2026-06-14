module CafeCar
  module UI
    include Resolver

    module_function

    def component(name, **, &)
      define_class(name, CafeCar[:Component], **, &)
    end
  end
end
