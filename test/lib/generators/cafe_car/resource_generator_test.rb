require "test_helper"
require "generators/cafe_car/resource/resource_generator"

# The resource generator is a thin orchestrator: it delegates to the model,
# cafe_car:controller, and cafe_car:policy generators (each covered by its own
# test). Running those inline would write outside the test destination, so we
# capture the delegations and assert resource wires them up with the right
# names instead.
class CafeCar::ResourceGeneratorTest < Rails::Generators::TestCase
  tests CafeCar::ResourceGenerator
  destination Rails.root.join("tmp/generators")
  setup :prepare_destination

  GENERATE_CALLS = []

  module CaptureGenerate
    def generate(what, *args)
      CafeCar::ResourceGeneratorTest::GENERATE_CALLS << [ what, args ]
      nil
    end
  end

  setup { CafeCar::ResourceGenerator.prepend(CaptureGenerate) }
  setup { GENERATE_CALLS.clear }

  def call_for(what) = GENERATE_CALLS.find { |name, _| name == what }

  test "delegates the model with the singular path and attributes" do
    run_generator [ "admin/invoices", "amount:integer", "memo:string" ]

    name, args = call_for("model")
    assert_equal "model", name
    assert_equal "admin/invoice", args.first
    attribute_names = args.select { |arg| arg.respond_to?(:name) }.map(&:name)
    assert_equal %w[amount memo], attribute_names
  end

  test "delegates the plural controller" do
    run_generator [ "admin/invoices" ]

    _name, args = call_for("cafe_car:controller")
    assert_equal "admin/invoices", args.first
  end

  test "delegates the policy with the singular path" do
    run_generator [ "admin/invoices" ]

    _name, args = call_for("cafe_car:policy")
    assert_equal "admin/invoice", args.first
  end

  test "drives all three sub-generators" do
    run_generator [ "admin/invoices" ]

    assert call_for("model"), "expected the model generator to run"
    assert call_for("cafe_car:controller"), "expected the controller generator to run"
    assert call_for("cafe_car:policy"), "expected the policy generator to run"
  end
end
