require "test_helper"
require "generators/cafe_car/sessions/sessions_generator"

class CafeCar::SessionsGeneratorTest < Rails::Generators::TestCase
  tests CafeCar::SessionsGenerator
  destination Rails.root.join("tmp/generators")
  setup :prepare_destination

  test "creates the sessions migration" do
    run_generator

    assert_migration "db/migrate/create_sessions.rb" do |migration|
      assert_match(/create_table :sessions/, migration)
      assert_match(/t\.references :user/, migration)
    end
  end

  test "does not create a model or policy" do
    run_generator

    assert_no_file "app/models/session.rb"
    assert_no_file "app/policies/session_policy.rb"
  end
end
