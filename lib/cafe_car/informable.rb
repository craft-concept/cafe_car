module CafeCar
  module Informable
    extend ActiveSupport::Concern

    def field(method)
      @field         ||= {}
      @field[method] ||= CafeCar[:Field].new(object: self, method:)
    end

    class_methods do
      def field_info(method)
        @field_info         ||= {}
        @field_info[method] ||= CafeCar[:FieldInfo].new(object: self, method:)
      end
    end
  end
end
