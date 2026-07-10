module CafeCar
  module Inputs
    # A masked `<input type="password">` for `has_secure_password` digests.
    class PasswordInput < BaseInput
      def helper   = :password_field
      def defaults = text_hints
    end
  end
end
