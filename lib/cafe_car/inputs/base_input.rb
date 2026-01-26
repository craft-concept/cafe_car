module CafeCar
  module Inputs
    class BaseInput
      attr_accessor :options

      def initialize(template:, **options)
        @template = template
        @options  = options
      end

      def tag  = :input
      def type = :text

      def to_html
        @template.Input(tag:, type:, **options)
      end
    end
  end
end
