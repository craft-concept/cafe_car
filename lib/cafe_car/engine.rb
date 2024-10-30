require "haml"

module CafeCar
  class Engine < ::Rails::Engine
    config.autoload_paths += paths["lib"].to_a
  end
end
