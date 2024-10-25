require "zeitwerk"

require "cafe_car/version"
require "cafe_car/engine"

loader = Zeitwerk::Loader.for_gem
loader.setup

module CafeCar
end
