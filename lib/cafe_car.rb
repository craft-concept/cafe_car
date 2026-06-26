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

  # Name of the host application's user model. Hosts with a differently named
  # user model can override this (e.g. `CafeCar.user_class_name = "Account"`).
  mattr_accessor :user_class_name, default: "User"

  # The host's user model, resolved lazily so the constant need not exist at
  # boot. Used by CafeCar::Session for authentication.
  def self.user_class = user_class_name.to_s.constantize

  # Whether the opt-in sessions/login infrastructure is available. True only
  # when the sessions table exists, so a CRUD-only host (no sessions migration)
  # degrades to 403 Forbidden instead of redirecting to a nonexistent login.
  def self.sessions_available?
    CafeCar[:Session].table_exists?
  rescue StandardError
    false
  end
end
