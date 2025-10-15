module CafeCar::Caching
  extend ActiveSupport::Concern

  def cache(name, &)
    instance_variable_get("@#{name}") || instance_variable_set("@#{name}", instance_exec(&))
  end

  class_methods do
    def derive(name, proc = nil, &block)
      proc ||= block
      define_method(name) { cache(name, &proc) }
    end

    def cache!(name)
      prepend Module.new.tap { _1.module_eval <<~RUBY }
        def #{name} = cache(:#{name}) { super }
      RUBY
    end
  end
end
