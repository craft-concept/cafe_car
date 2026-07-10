module CafeCar
  class FilterBuilder
    delegate :model_name, :klass, to: :@objects

    def initialize(objects, params)
      @objects = objects
      @params  = params
    end

    def model      = @objects.klass
    def to_key     = [ model_name.param_key, :filters ]
    def to_model   = self
    def persisted? = false
    def errors     = Hash.new([])

    # Rails' select/check_box read the current value off the object by the field
    # name (`object.status`); a nested control's name is a dot-path
    # (`client.status`), so split it to dig the nested param — the same segment
    # walk as #value.
    def method_missing(name, *, &)
      @params.dig("", *name.to_s.split("."))
    end

    # Current value of a (possibly nested) filter param — `value(:price, :min)`
    # reads `?price.min=`, and `value("client.owner_id")` digs the nested
    # `?client.owner_id=` a nested control posts (a dotted key splits into its
    # segments). Nil-safe against shapes a control can't express (a hand-typed
    # `?price=10..20` parses to a Range, not a Hash).
    def value(*keys)
      keys.flat_map { _1.to_s.split(".") }.reduce(@params[""]) { |v, key| v[key] if v.is_a?(Hash) }
    end
  end
end
