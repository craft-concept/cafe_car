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

    def method_missing(name, *, &)
      @params.dig("", name)
    end

    # Current value of a (possibly nested) filter param — `value(:price, :min)`
    # reads `?price.min=`. Nil-safe against shapes a control can't express
    # (a hand-typed `?price=10..20` parses to a Range, not a Hash).
    def value(*keys)
      keys.map!(&:to_s).reduce(@params[""]) { |v, key| v[key] if v.is_a?(Hash) }
    end
  end
end
