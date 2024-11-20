module CafeCar::Filterable
  extend ActiveSupport::Concern

  class_methods do
    def filtered(params)  = filter_builder.filter(params).scope
    def filtered!(params) = filter_builder.filter!(params).scope

    def filter_builder
      CafeCar::FilterBuilder.new(self)
    end
  end
end
