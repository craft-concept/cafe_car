require "haml"
require "kaminari"
require "image_processing"
require "propshaft"
require "pundit"
require "importmap-rails"
require "turbo-rails"

module CafeCar
  class Engine < ::Rails::Engine
    config.autoload_paths += paths["lib"].to_a

    initializer "cafe_car.i18n" do |app|
      app.reloader.to_prepare do
        CafeCar::NamePatch.patch!
        I18n::Backend::Simple.include(CafeCar::Pluralization)
      end
    end

    initializer "cafe_car.assets" do |app|
      app.config.assets.paths << root.join("app/javascript")
    end

    initializer "cafe_car.importmap", before: "importmap" do |app|
      app.config.importmap.paths << root.join("config/importmap.rb")
      app.config.importmap.cache_sweepers << root.join("app/assets/javascripts")
    end

    initializer "cafe_car.active_record" do |app|
      app.reloader.to_prepare do
        ::ActiveRecord::Base.include(CafeCar::Model)
      end
    end
  end
end
