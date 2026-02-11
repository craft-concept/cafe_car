module CafeCar
  module UI
    module_function

    def component(name, **, &)
      define_class(name, const(:Component), **, &)
    end
  end
end
