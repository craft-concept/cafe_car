module CafeCar
  module Inputs
    # A `<select>` of an ActiveRecord enum's declared values. Delegates to the form
    # builder's `enum`, which reads the choices off `defined_enums` and prepends the
    # locale prompt as the blank option.
    class SelectInput < BaseInput
      def helper = :enum
    end
  end
end
