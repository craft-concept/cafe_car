module CafeCar::Table
  class ObjectsBuilder < Builder
    option :objects, default: -> { raise }

    def model                = @objects
    def policy(o = @objects) = @template.policy(o)
  end
end
