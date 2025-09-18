require "test_helper"
require "generators/cafe_car/install/install_generator"

class CafeCar::InstallGeneratorTest < Rails::Generators::TestCase
  tests CafeCar::InstallGenerator
  destination Rails.root.join("tmp/generators")
  setup :prepare_destination

  # test "generator runs without errors" do
  #   assert_nothing_raised do
  #     run_generator ["arguments"]
  #   end
  # end
end
