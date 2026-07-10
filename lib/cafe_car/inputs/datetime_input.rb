module CafeCar
  module Inputs
    # A native `<input type="datetime-local">` for datetime columns.
    class DatetimeInput < BaseInput
      def helper = :datetime_field
    end
  end
end
