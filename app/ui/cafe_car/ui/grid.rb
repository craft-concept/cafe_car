module CafeCar
  module UI
    component :Grid do
      option :columns
      option :template
      option :style

      def attributes
        super.merge(style:)
      end

      def style
        style = [*@style]
        style << "grid-template: #{template}" if template?
        style << "grid-template-columns: #{columns}" if columns?
        style.compact_blank.join("; ").presence
      end

      def columns
        case @columns
        in Numeric
          "repeat(#{@columns}, 1fr)"
        in [a, b]
          "repeat(auto-fill, minmax(#{a}, #{b}))"
        else @columns
        end
      end
    end
  end
end
