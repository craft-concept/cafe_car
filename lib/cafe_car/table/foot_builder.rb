module CafeCar::Table
  class FootBuilder < ObjectsBuilder
    def initialize(...)
      super
      @count   = 0
    end

    def cell!           = (@count += 1; nil)
    def cell(...)       = (super; cell!)
    def controls(...)   = cell!

    def to_html = ""
  end
end
