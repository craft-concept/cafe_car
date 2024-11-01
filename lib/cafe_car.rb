require "cafe_car/version"
require "cafe_car/engine"

module CafeCar
  def self.[](const)
    [Object, CafeCar].lazy
                     .select { _1.const_defined?(const) }
                     .map { _1.const_get(const) }
                     .first
  end
end
