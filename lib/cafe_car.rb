require "cafe_car/core_ext"

require "cafe_car/version"
require "cafe_car/engine"
require "cafe_car/resolver"
require "cafe_car/auto_resolver"
require "cafe_car/proc_helpers"

module CafeCar
  include Resolver
  extend AutoResolver
  extend ProcHelpers

  class MissingAttributeError < StandardError
  end

  class AuthenticationFailed < StandardError
  end

  def self.use_relative_model_naming? = true
end
