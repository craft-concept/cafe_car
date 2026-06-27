require "test_helper"
require "generators/cafe_car/controller/controller_generator"
require_relative "host_skeleton"

class CafeCar::ControllerGeneratorTest < Rails::Generators::TestCase
  include HostSkeleton

  tests CafeCar::ControllerGenerator
  destination Rails.root.join("tmp/generators")
  setup :prepare_destination
  setup :build_host_skeleton

  test "creates a namespaced controller that calls cafe_car" do
    run_generator [ "admin/products" ]

    assert_file "app/controllers/admin/products_controller.rb" do |controller|
      assert_match(/module Admin/, controller)
      assert_match(/class ProductsController < ApplicationController/, controller)
      assert_match(/^\s+cafe_car$/, controller)
    end
  end

  test "adds a plural resources route in the namespace" do
    run_generator [ "admin/products" ]

    assert_file "config/routes.rb" do |routes|
      assert_match(/namespace :admin do/, routes)
      assert_match(/resources :products/, routes)
    end
  end

  test "skips routes when asked" do
    run_generator [ "admin/products", "--skip-routes" ]

    assert_file "config/routes.rb" do |routes|
      assert_no_match(/resources :products/, routes)
    end
  end

  test "uses a singular resource route for a singular name" do
    run_generator [ "dashboard", "--skip-routes" ]

    assert_file "app/controllers/dashboard_controller.rb" do |controller|
      assert_match(/class DashboardController < ApplicationController/, controller)
    end
  end
end
