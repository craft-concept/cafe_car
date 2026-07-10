module CafeCar
  module Inputs
    # A numeric `<input type="number">` for integer columns.
    class NumberInput < BaseInput
      def helper   = :number_field
      def defaults = text_hints
    end
  end
end
