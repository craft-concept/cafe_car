require "zeitwerk"

require "cafe_car/version"
require "cafe_car/engine"

loader = Zeitwerk::Loader.for_gem
loader.inflector.inflect('ui' => 'UI')
loader.setup

module CafeCar
end
