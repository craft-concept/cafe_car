require "haml"

module CafeCar
  class Engine < ::Rails::Engine
    config.autoload_paths += paths["lib"].to_a

    initializer "cafe_car.i18n" do |app|
        app.reloader.to_prepare do
          CafeCar::NamePatch.patch!
          I18n::Backend::Simple.include(CafeCar::Pluralization)
        end
      end
  end
end
