module CafeCar::Table
  class HeadBuilder < ObjectsBuilder
    def cell(method, **_, &_)
      label = LabelBuilder.new(@template, objects: @objects, method:)
      ui.cell label
    end

    def controls(...)   = ui.cell
    def to_html         = ui.head(:sticky, capture(self, &@block))
  end
end
