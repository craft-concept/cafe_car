module CafeCar::Queryable
  extend ActiveSupport::Concern

  class_methods do
    def scope(name, body)
      scopes[name] = body
      super
    end

    def query(params)  = query_builder.query(params).scope
    def query!(params) = query_builder.query!(params).scope

    def query_builder
      CafeCar::QueryBuilder.new(self)
    end

    def scopes
      @scopes ||= {}.with_indifferent_access
    end

    def local_methods
      @local_methods ||= public_methods -
        ActiveRecord::Base.public_methods -
        Kaminari::ConfigurationMethods::ClassMethods.instance_methods
    end
  end
end
