class CafeCar::SessionsGenerator < Rails::Generators::Base
  include CafeCar::Generators

  source_root File.expand_path("templates", __dir__)

  def install_bcrypt
    gem "bcrypt"
    bundle_command "install"
  end

  def create_sessions
    migration "create_sessions"
  end

  def show_readme
    return unless behavior == :invoke

    say <<~MSG

      CafeCar sessions are enabled. The Session model and SessionPolicy ship
      with the engine, so this adds bcrypt and the `sessions` table.

      Next:
        - Run `bin/rails db:migrate`.
        - Make sure your user model has `has_secure_password` and an `email`.
        - Mounting the engine exposes /session (login). To expose it without
          mounting, add to config/routes.rb:
            resource :session, only: %i[new create destroy],
                     controller: "cafe_car/sessions"
        - If your user model isn't `User`, set CafeCar.user_class_name in an
          initializer (e.g. `CafeCar.user_class_name = "Account"`).
    MSG
  end
end
