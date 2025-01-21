require "test_helper"
require "generators/cafe_car/policy/policy_generator"

class CafeCar::PolicyGeneratorTest < Rails::Generators::TestCase
  tests CafeCar::PolicyGenerator
  destination Rails.root.join("tmp/generators")
  setup :prepare_destination

  test "generator runs without errors" do
    assert_nothing_raised do
      run_generator ["admin/payments"]
    end
  end
end
