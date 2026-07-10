module CafeCar
  module Inputs
    # A multi-line `<textarea>` for text/json columns.
    class TextAreaInput < BaseInput
      def helper   = :text_area
      def defaults = text_hints
    end
  end
end
