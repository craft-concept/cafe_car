module CafeCar::Table
  class FootBuilder < Builder
    def initialize(...)
      super
      @objects = @options.delete(:objects)
      @count   = 0
    end

    def cell!           = (@count += 1; nil)
    def cell(...)       = cell!
    def timestamps(...) = cell!
    def controls(...)   = cell!

    def to_html = ""
  end
end
