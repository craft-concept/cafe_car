require "test_helper"
require "generators/cafe_car/install/install_generator"
require_relative "host_skeleton"

class CafeCar::InstallGeneratorTest < Rails::Generators::TestCase
  include HostSkeleton

  tests CafeCar::InstallGenerator
  destination Rails.root.join("tmp/generators")
  setup :prepare_destination
  setup :build_host_skeleton

  # `bundle install` shells out to a real bundle run; no-op it so the test
  # exercises the file mutations without touching the network.
  setup { CafeCar::InstallGenerator.prepend(SkipBundle) }

  module SkipBundle
    def bundle_command(*) = nil
  end

  test "adds the runtime gems to the Gemfile" do
    run_generator

    assert_file "Gemfile" do |gemfile|
      assert_match(/gem "bcrypt"/, gemfile)
      assert_match(/gem "paper_trail"/, gemfile)
      assert_match(/gem "factory_bot_rails"/, gemfile)
      assert_match(/gem "faker"/, gemfile)
      assert_match(/gem "rouge"/, gemfile)
    end
  end

  test "adds the development gems in a development group" do
    run_generator

    assert_file "Gemfile" do |gemfile|
      assert_match(/group :development do/, gemfile)
      assert_match(/gem "hotwire-livereload"/, gemfile)
      assert_match(/gem "better_errors"/, gemfile)
      assert_match(/gem "binding_of_caller"/, gemfile)
      assert_match(/gem "chrome_devtools_rails"/, gemfile)
      assert_match(/gem "i18n-debug"/, gemfile)
    end
  end

  test "mounts the engine under the admin namespace" do
    run_generator

    assert_file "config/routes.rb" do |routes|
      assert_match(/namespace :admin do/, routes)
      assert_match(%r{mount CafeCar::Engine => "/"}, routes)
    end
  end

  test "creates an ApplicationPolicy from the template" do
    run_generator

    assert_file "app/policies/application_policy.rb" do |policy|
      assert_match(/class ApplicationPolicy < CafeCar::ApplicationPolicy/, policy)
      assert_match(/class Scope < Scope/, policy)
    end
  end

  test "includes CafeCar::Controller in ApplicationController" do
    run_generator

    assert_file "app/controllers/application_controller.rb" do |controller|
      assert_match(/class ApplicationController/, controller)
      assert_match(/  include CafeCar::Controller/, controller)
    end
  end

  test "wires the JavaScript imports" do
    run_generator

    assert_file "app/javascript/application.js" do |js|
      assert_match(/import "cafe_car"/, js)
      assert_match(/import "trix"/, js)
      assert_match(/import "@rails\/actiontext"/, js)
    end
  end
end
