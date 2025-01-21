require "rails/generators/resource_helpers"

class CafeCar::ModelGenerator < Rails::Generators::NamedBase
  source_root File.expand_path("templates", __dir__)

  def create_model
    template "model.rb", File.join("app/controllers", controller_class_path, "#{controller_file_name}_controller.rb")
  end

  private

  def base_controller_name
    return "ApplicationController" if controller_class_path.empty?
    (controller_class_path + ["BaseController"]).join("::")
  end

  def policy_class_name
    name.camelize
  end

  def base_policy_name
    "ApplicationPolicy"
  end
end
