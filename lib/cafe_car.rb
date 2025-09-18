require "cafe_car/version"
require "cafe_car/engine"
require "cafe_car/resolver"
require "cafe_car/proc_helpers"

module CafeCar
  include Resolver
  extend ProcHelpers
end
