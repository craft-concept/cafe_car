module CafeCar
  class TableBuilder < Table::Builder
    def to_html
      @template.ui.table do |table|
        table << Table::HeadBuilder.new(@template, **@options, &@block)
        table << Table::BodyBuilder.new(@template, **@options, &@block)
        table << Table::FootBuilder.new(@template, **@options, &@block)
      end
    end
  end
end
