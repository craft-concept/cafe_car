class CafeCar::ControllerGenerator < Rails::Generators::NamedBase
  include CafeCar[:Generators]

  source_root File.expand_path("templates", __dir__)

  class_option :skip_routes, type: :boolean, desc: "Don't add routes to config/routes.rb."

  check_class_collision suffix: "Controller"

  def create_controller
    template "controller.rb", File.join("app/controllers", class_path, "#{file_name}_controller.rb")
  end

  def add_resource_route
    return if options.skip_routes?
    route "#{resources} :#{file_name}", namespace: regular_class_path
  end

  private

  def class_name           = file_name.camelize
  def plural?              = file_name == plural_file_name
  def plural_count         = plural? ? 2 : 1
  def resources            = "resource".pluralize(plural_count)
  def base_controller_name = "ApplicationController"
end
