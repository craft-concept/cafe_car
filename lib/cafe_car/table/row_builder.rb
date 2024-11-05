module CafeCar
  module Table
    class RowBuilder < Builder
      def value(method) = present(@object).public_send(method)

      def cell(method, **options, &block)
        ui.cell do
          if block
            ui << capture(value(method), &block)
          else
            ui << present(value(method))
          end
        end
      end

      def controls(...)
        ui.cell(present(@object).controls(...))
      end

      def to_html
        ui.row(capture(self, &@block))
      end
    end
  end
end
