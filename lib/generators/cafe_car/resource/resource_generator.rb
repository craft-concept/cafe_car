require "rails/generators/resource_helpers"

class CafeCar::ResourceGenerator < Rails::Generators::NamedBase
  include Rails::Generators::ResourceHelpers
  include CafeCar::Generators

  source_root File.expand_path("templates", __dir__)
  argument :attributes, type: :array, default: [], banner: "field[:type][:index] field[:type][:index]"

  def create_model
    generate "model", file_path, *attributes, force
  end

  def create_controller
    generate "cafe_car:controller", controller_name, force
  end

  def create_policy
    generate "cafe_car:policy", file_path, force
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
