module CafeCar::Table
  class ObjectsBuilder < Builder
    def initialize(...)
      super
      @objects = @options.delete(:objects) { raise }
    end

    def model                = @objects
    def policy(o = @objects) = @template.policy(o)
  end
end
