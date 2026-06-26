# frozen_string_literal: true

class Module
  # Shorthand for `const_set(name.camelize, Class.new(parent) { ... })`.
  # Useful when defining classes in macros.
  def define_class(name, *, **macros, &)
    name = name.to_s.camelize
    raise NameError, "class exists: #{name}" if const_defined?(name, false)
    klass = Class.new(*) do
      macros.each { |key, value| send(key, *value) }
      class_eval(&) if block_given?
    end
    const_set name, klass
  end
end
