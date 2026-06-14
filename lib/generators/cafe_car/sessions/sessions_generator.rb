class CafeCar::SessionsGenerator < Rails::Generators::Base
  include CafeCar::Generators

  source_root File.expand_path("templates", __dir__)

  def create_sessions
    migration "create_sessions"
    # template "session.rb", "app/models/session.rb"
  end
end
