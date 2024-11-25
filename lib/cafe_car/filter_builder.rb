module CafeCar
  class FilterBuilder
    delegate :model_name, :klass, to: :@objects

    def initialize(objects, params)
      @objects = objects
      @params  = params
    end

    def model      = @objects.klass
    def to_key     = [model_name.param_key, :filters]
    def to_model   = self
    def persisted? = false
    def errors     = Hash.new([])

    def method_missing(name, *, &)
      @params.dig("", name)
    end
  end
end
