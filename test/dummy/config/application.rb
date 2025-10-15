require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Dummy
  class Application < Rails::Application
    config.load_defaults Rails::VERSION::STRING.to_f
    config.autoload_lib(ignore: %w[assets tasks])
    config.time_zone = ENV["TZ"] || "America/Detroit"
    # config.railties_order = [:all, :main_app]
  end
end
