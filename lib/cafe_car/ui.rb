module CafeCar
  module UI
    module_function

    def component(name, **, &)
      define_class(name, CafeCar[:Component], **, &)
    end
  end
end
