module CafeCar
  module Inputs
    # A free-text `<input type="text">` — the default for string/decimal columns.
    class StringInput < BaseInput
      def helper   = :text_field
      def defaults = text_hints
    end
  end
end
