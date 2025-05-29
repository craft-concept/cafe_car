module CafeCar
  class TableBuilder < Table::Builder
    def to_html
      head    = Table::HeadBuilder.new(@template, **@options, &@block).tap(&:to_s)
      columns = head.fields.map(&:width).join(" ")
      @template.ui.table style: "grid-template-columns: #{columns}" do |table|
        table << head
        table << Table::BodyBuilder.new(@template, **@options, &@block)
        table << Table::FootBuilder.new(@template, **@options, &@block)
      end
    end
  end
end
