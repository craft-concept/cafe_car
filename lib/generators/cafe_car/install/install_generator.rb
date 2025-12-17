class CafeCar::InstallGenerator < Rails::Generators::Base
  include CafeCar::Generators

  source_root File.expand_path("templates", __dir__)

  def install_deps
    gem "cnc", github: "craft-concept/cnc"
    gem "bcrypt"
    gem "paper_trail"
    gem "factory_bot_rails"
    gem "faker"
    gem "rouge"

    gem_group :development do
      gem "hotwire-livereload"
      gem "better_errors"
      gem "binding_of_caller"
      gem "chrome_devtools_rails"
      gem "i18n-debug"
    end
    bundle_command "install"
  end

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
