require "rails/generators/resource_helpers"

class CafeCar::ResourceGenerator < Rails::Generators::NamedBase
  include Rails::Generators::ResourceHelpers

  source_root File.expand_path("templates", __dir__)

  def create_controller
    generate "cafe_car:controller", controller_name, force, inline: true
  end

  def create_policy
    generate "cafe_car:policy", file_path, force, inline: true
  end

  private

  def assign_controller_names!(...)
    if options[:model_name].blank?
      assign_names!(file_name)
    end

    super
  end

  def force = options.force? ? "--force" : ""
end
