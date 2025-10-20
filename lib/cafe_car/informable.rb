module CafeCar
  module Informable
    extend ActiveSupport::Concern

    class_methods do
      def info = CafeCar[:ModelInfo].find(self)
    end
  end
end
