module CafeCar::Table
  class HeadBuilder < Builder
    def initialize(...)
      super
      @objects = @options.delete(:objects) { raise }
    end

    def cell(method, **_, &_)
      label = LabelBuilder.new(@template, objects: @objects, method:)
      ui.cell label
    end

    def timestamps(...) = cell(:updated_at)
    def controls(...)   = ui.cell # cell(:updated_at)
    def to_html         = ui.head(:sticky, capture(self, &@block))
  end
end
