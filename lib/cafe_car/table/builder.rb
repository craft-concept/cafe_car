module CafeCar
  module Table
    class Builder
      attr_reader :ui
      delegate :capture, :present, to: :@template

      def initialize(template, object, **options, &block)
        @template = template
        @object   = object
        @options  = options
        @block    = block
        @ui       = @template.ui.table.context
      end

      def html_safe? = true
      def to_s       = to_html.to_s
    end
  end
end
