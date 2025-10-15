module CafeCar
  class ModelInfo
    include Caching

    attr_reader :model, :object

    def self.find(klass)
      @cache        ||= {}
      @cache[klass] ||= new(klass)
    end

    def initialize(object)
      @object = object
      @model  = object.is_a?(Class) ? object : object.class
      @field  = {}
    end

    def columns         = model.column_names
    def field(method)   = @field[method]   ||= FieldInfo.new(object:, method:)

    derive :fields, -> { Fields.new(columns.map { field _1 }) }
  end
end
