require "chronic"
require "haml-rails"
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

    initializer "cafe_car.filter_parameters" do |app|
      app.config.filter_parameters |= %i[authorization passw secret token _key crypt salt certificate otp ssn]
    end

    initializer "cafe_car.importmap", before: "importmap" do |app|
      app.config.importmap.paths << root.join("config/importmap.rb")
      app.config.importmap.cache_sweepers << root.join("app/javascript")
    end

    initializer "cafe_car.active_record" do |app|
      app.reloader.to_prepare do
        ::ActiveRecord::Base.include(Model)
      end
    end

    initializer "cafe_car.routing" do |app|
      app.reloader.to_prepare do
        ::ActionDispatch::Routing::Mapper.include(Routing)
      end
    end

    initializer "cafe_car.chronic" do |app|
      app.reloader.to_prepare do
        Chronic.time_class = Time.zone
      end
    end

    initializer "cafe_car.sqlite_regexp" do |app|
      ActiveSupport.on_load :active_record_sqlite3adapter do
        ::Arel::Visitors::SQLite.include(Visitors::SQLite)
        include ActiveRecord::SQLite3Extension
      end
    end

    initializer "cafe_car.turbo" do
      ActiveSupport.on_load :turbo_streams_tag_builder do
        include TurboTagBuilder
      end
    end

    initializer "cafe_car.field_with_errors" do
      ActionView::Base.field_error_proc = proc { _1.html_safe }
    end

    initializer "cafe_car.console" do |app|
      app.console do
        TOPLEVEL_BINDING.eval('self').instance_exec do
          def logger = Rails.logger

          if defined?(FactoryBot)
            include FactoryBot::Syntax::Methods
            logger.info "FactoryBot methods enabled."
          end

          logger.info 'SQL logs enabled.'

          ApplicationController.allow_forgery_protection = false
          logger.info "CSRF disabled to enable app.post calls."

          def present(...) = CafeCar[:Presenter].present(helper, ...)
        end
      end
    end
  end
end
