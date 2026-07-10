module CafeCar
  module Inputs
    # A native `<input type="checkbox">` (with Rails' companion hidden field) for
    # boolean columns, themed as a CafeCar control by `ui/Input.css`.
    class BooleanInput < BaseInput
      def helper = :check_box
    end
  end
end
