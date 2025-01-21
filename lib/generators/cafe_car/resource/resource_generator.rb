require "rails/generators/resource_helpers"

class CafeCar::ResourceGenerator < Rails::Generators::NamedBase
  include Rails::Generators::ResourceHelpers

  source_root File.expand_path("templates", __dir__)

  def create_controller
    generate "cafe_car:controller", controller_file_path, inline: true
  end

  def create_policy
    generate "cafe_car:policy", controller_file_path, inline: true
  end
end
