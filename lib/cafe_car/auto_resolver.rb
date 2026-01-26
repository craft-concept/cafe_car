module CafeCar
  module AutoResolver
    def auto_resolve!(mod)
      mod.instance_eval <<~RUBY, __FILE__, __LINE__
        def const_missing(name)
          super
        rescue NameError
          CafeCar.define(self, name) or raise
        end
      RUBY
    end

    def define(mod, name)
      case name.to_s
      when /^\w+Controller$/
        TOPLEVEL_BINDING.eval <<~RUBY, __FILE__, __LINE__
          class #{mod.name}::#{name} < CafeCar[:ApplicationController]
            include CafeCar::Controller
            recline_in_the_cafe_car
            self
          end
        RUBY
      when /^\w+Policy$/
        TOPLEVEL_BINDING.eval <<~RUBY, __FILE__, __LINE__
          class #{mod.name}::#{name} < CafeCar[:ApplicationPolicy]
            def admin? = Rails.env.development?

            def index?   = admin?
            def show?    = admin?
            def create?  = admin?
            def update?  = admin?
            def destroy? = admin?

            def permitted_attributes
              model.info.fields.names.then do |names|
                [*model.primary_key].reverse.map(&:to_sym) & names | names
              end
            end

            class Scope < Scope
              def resolve = scope.all
            end
            self
          end
        RUBY
      end
    end
  end
end
