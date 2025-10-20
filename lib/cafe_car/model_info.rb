module CafeCar
  class ModelInfo
    include Caching

    attr_reader :model

    def self.find(object)
      model = object.is_a?(Class) ? object : object.class
      @cache        ||= {}
      @cache[model] ||= new(model:)
    end

    def initialize(model:)
      @model  = model
      @field  = {}
    end

    def columns         = model.column_names
    def field_names     = model.column_names | model.reflect_on_all_attachments.map(&:name)
    def field(method)   = @field[method]   ||= FieldInfo.new(model:, method:)

    derive :fields, -> { Fields.new(field_names.map { field _1 }) }
  end
end
