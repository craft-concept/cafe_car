module CafeCar::Table
  class HeadBuilder < ObjectsBuilder
    attr_reader :fields

    def initialize(...)
      @fields = []
      super
    end

    def cell(method, *flags, label: label(method), **, &)
      super
      @fields << model.field_info(method)
      ui.cell(label, *flags)
    end

    def label(method)
      l = LabelBuilder.new(@template, objects: @objects, method:)
      @objects.includes!(method) if l.association?
      l
    end

    def controls(*, **) = cell(:controls, :controls, *, label: nil, **)

    def to_html = ui.head(:sticky, capture(self, &@block))
  end
end
