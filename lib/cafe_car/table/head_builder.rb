module CafeCar
  module Table
    class HeadBuilder < Builder
      def cell(method, **_, &_)
        ui.cell { method.to_s.humanize }
      end

      def controls(...) = ui.cell("Controls")

      def to_html = ui.head(capture(self, &@block))
    end
  end
end
