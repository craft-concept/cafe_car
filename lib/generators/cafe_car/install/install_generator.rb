class CafeCar::InstallGenerator < Rails::Generators::Base
  include CafeCar::Generators

  source_root File.expand_path("templates", __dir__)

  def routes
    route %(mount CafeCar::Engine => "/"), namespace: :admin
  end

  def install_pundit
    template "application_policy.rb", "app/policies/application_policy.rb"
  end

  def install_js
    inside "app/javascript" do
      append_to_file "application.js", <<~JS
        import "cafe_car"
        import "trix"
        import "@rails/actiontext"
      JS
    end
  end

  def install_controller
    inject_into_class "app/controllers/application_controller.rb", "ApplicationController" do
      "  include CafeCar::Controller\n"
    end
  end
end
