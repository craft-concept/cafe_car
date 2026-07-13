require "test_helper"
require "generators/cafe_car/sessions/sessions_generator"
require_relative "host_skeleton"

class CafeCar::SessionsGeneratorTest < Rails::Generators::TestCase
  include HostSkeleton

  tests CafeCar::SessionsGenerator
  destination Rails.root.join("tmp/generators")
  setup :prepare_destination
  setup :build_host_skeleton
  setup { CafeCar::SessionsGenerator.prepend(SkipBundle) }

  module SkipBundle
    def bundle_command(*) = nil
  end

  test "adds bcrypt to the Gemfile" do
    run_generator

    assert_file "Gemfile", /gem "bcrypt"/
  end

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
