module CafeCar
  class TableBuilder < Table::Builder
    def to_html
      @template.ui.table do |table|
        table << Table::HeadBuilder.new(@template, @object, **@options, &@block)
        table << Table::BodyBuilder.new(@template, @object, **@options, &@block)
        # table << table.foot("Table foot")
      end
    end
  end
end
