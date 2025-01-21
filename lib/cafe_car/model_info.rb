module CafeCar
  class ModelInfo
    attr_reader :model, :object

    def initialize(object)
      @object = object
      @model  = object.is_a?(Class) ? object : object.class
      @field  = {}
    end

    def columns         = model.column_names
    def field(method)   = @field[method] ||= FieldInfo.new(object:, method:)
    def fields          = @fields        ||= columns.map { field _1 }
    def editable_fields = fields.reject(&:constant?)
  end
end
