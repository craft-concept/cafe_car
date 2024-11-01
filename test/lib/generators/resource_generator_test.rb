require "test_helper"
require "generators/cafe_car/resource/resource_generator"

class ResourceGeneratorTest < Rails::Generators::TestCase
  tests ResourceGenerator
  destination Rails.root.join("tmp/generators")
  setup :prepare_destination

  # test "generator runs without errors" do
  #   assert_nothing_raised do
  #     run_generator ["arguments"]
  #   end
  # end
end
