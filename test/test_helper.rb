# Configure Rails Environment
ENV["RAILS_ENV"] = "test"

require_relative "../test/dummy/config/environment"
ActiveRecord::Migrator.migrations_paths = [ File.expand_path("../test/dummy/db/migrate", __dir__) ]
require "rails/test_help"

# Load fixtures from the engine
if ActiveSupport::TestCase.respond_to?(:fixture_paths=)
  ActiveSupport::TestCase.fixture_paths         = [ File.expand_path("fixtures", __dir__) ]
  ActionDispatch::IntegrationTest.fixture_paths = ActiveSupport::TestCase.fixture_paths
  ActiveSupport::TestCase.file_fixture_path     = File.expand_path("fixtures", __dir__) + "/files"
  ActiveSupport::TestCase.fixtures :all
end

ActiveSupport::TestCase.include FactoryBot::Syntax::Methods

module SignInHelper
  # Logs in through the real session flow so requests have a current_user.
  def sign_in(user = create(:user, password: "secret", password_confirmation: "secret"))
    post "/session", params: { session: { email: user.email, password: "secret" } }
    user
  end
end

ActionDispatch::IntegrationTest.include SignInHelper
