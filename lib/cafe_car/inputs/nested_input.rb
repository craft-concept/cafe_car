module CafeCar
  module Inputs
    # The `fields_for` sub-form for a `accepts_nested_attributes_for` association.
    # Delegates to the form builder's `fields_for`, which renders each child record's
    # remaining fields (or the caller's block).
    class NestedInput < BaseInput
      def helper = :fields_for
    end
  end
end
