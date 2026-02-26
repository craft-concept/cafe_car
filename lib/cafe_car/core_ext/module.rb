class Module
  def define_class(name, parent = nil, **macros, &)
    name = name.to_s.camelize
    raise NameError, "class exists: #{name}" if const_defined?(name, false)
    klass = Class.new(parent) do
      macros.each {|key, value| send(key, *value) }
      class_eval(&)
    end
    const_set name, klass
  end
end
