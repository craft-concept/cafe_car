module CafeCar
  module Inputs
    # A native date picker `<input type="date">` for date columns.
    class DateInput < BaseInput
      def helper = :date_field
    end
  end
end
