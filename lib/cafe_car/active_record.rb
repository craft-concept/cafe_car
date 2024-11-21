module CafeCar::ActiveRecord
  module SQLite3Extension
    extend ActiveSupport::Concern

    included do
      alias_method :pre_cafe_car_initialize, :initialize
      private :pre_cafe_car_initialize

      def initialize(*args)
        pre_cafe_car_initialize(*args)

        raw_connection.create_function('regexp', -1) do |func, pattern, expression, case_sensitive|
          options     = 0
          options    |= Regexp::IGNORECASE if case_sensitive.zero?
          pattern     = Regexp.new(pattern.to_s, options)
          func.result = expression.to_s.match(pattern) ? 1 : 0
        end
      end
    end
  end
end
