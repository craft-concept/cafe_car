class CafeCar::InstallGenerator < Rails::Generators::Base
  include CafeCar::Generators

  source_root File.expand_path("templates", __dir__)

  def install_js
    inside "app/javascript" do
      append_to_file "application.js", 'import "cafe_car"'
      append_to_file "application.js", 'import "trix"'
      append_to_file "application.js", 'import "@rails/actiontext"'
    end
  end

  def install_controller
    inject_into_class "app/controllers/application_controller.rb", "ApplicationController" do
      "include CafeCar::Controller"
    end
  end
end
