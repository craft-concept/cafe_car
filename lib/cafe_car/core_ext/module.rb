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

  def const_cache(name)
    name = name.to_s.gsub('::', ?_)
    const_defined?(name, false) ? const_get(name) : const_set(name, yield(name))
  end
end
