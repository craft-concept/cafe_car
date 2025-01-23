module CafeCar::Table
  class HeadBuilder < ObjectsBuilder
    def cell(method, *flags, label: label(method), **, &)
      super
      ui.cell(label, *flags)
    end

    def label(method)
      l = LabelBuilder.new(@template, objects: @objects, method:)
      @objects.includes!(method) if l.association?
      l
    end

    def controls(*, **) = ui.cell(:controls, :controls, *, **)

    def to_html = ui.head(:sticky, capture(self, &@block))
  end
end
