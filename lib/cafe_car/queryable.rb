module CafeCar::Queryable
  extend ActiveSupport::Concern

  class_methods do
    def query(params)  = query_builder.query(params).scope
    def query!(params) = query_builder.query!(params).scope

    def query_builder
      CafeCar::QueryBuilder.new(self)
    end
  end
end
