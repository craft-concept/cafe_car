require "test_helper"
require "generators/cafe_car/resource/resource_generator"
require_relative "host_skeleton"

# The resource generator is a thin orchestrator: it delegates to the model,
# cafe_car:controller, and cafe_car:policy generators (each covered by its own
# test). Here we capture the delegations and assert resource wires them up with
# the right names. Capturing on a subclass (rather than prepending the shared
# generator) keeps the stub from leaking into the inline test below.
class CafeCar::ResourceGeneratorTest < Rails::Generators::TestCase
  GENERATE_CALLS = []

  class CapturingResourceGenerator < CafeCar::ResourceGenerator
    private

    def generate(what, *args)
      GENERATE_CALLS << [ what, args ]
      nil
    end
  end

  tests CapturingResourceGenerator
  destination Rails.root.join("tmp/generators")
  setup :prepare_destination
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

  test "forwards the field names (not raw field:type args) to the policy" do
    run_generator [ "admin/invoices", "amount:integer", "memo:string" ]

    _name, args = call_for("cafe_car:policy")
    assert_includes args, "amount"
    assert_includes args, "memo"
    refute_includes args, "amount:integer"
  end

  test "forwards a :references field as its foreign key, not the bare association" do
    run_generator [ "admin/invoices", "client:references", "amount:integer" ]

    _name, args = call_for("cafe_car:policy")
    # strong-params receives `client_id`, never bare `client`.
    assert_includes args, "client_id"
    refute_includes args, "client"
  end

  test "forwards a polymorphic :references field as both _id and _type" do
    run_generator [ "admin/invoices", "owner:references{polymorphic}" ]

    _name, args = call_for("cafe_car:policy")
    assert_includes args, "owner_id"
    assert_includes args, "owner_type"
    refute_includes args, "owner"
  end

  test "drives all three sub-generators" do
    run_generator [ "admin/invoices" ]

    assert call_for("model"), "expected the model generator to run"
    assert call_for("cafe_car:controller"), "expected the controller generator to run"
    assert call_for("cafe_car:policy"), "expected the policy generator to run"
  end
end

# Runs the sub-generators for real (no capture) to prove the inline delegation
# writes into THIS generator's destination instead of leaking into the engine
# repo via Rails::Command.root.
class CafeCar::ResourceGeneratorInlineTest < Rails::Generators::TestCase
  include HostSkeleton

  tests CafeCar::ResourceGenerator
  destination Rails.root.join("tmp/generators")
  setup :prepare_destination
  setup :build_host_skeleton

  ENGINE_ROUTES = CafeCar::Engine.root.join("config/routes.rb")

  # Uses a name the dummy app doesn't already define, so the sub-generators'
  # class-collision checks don't fire on the test fixtures. The model
  # delegation is a stock Rails `hook_for :orm` pass-through that no-ops when no
  # ORM is configured (as in this dummy app), so we assert on the controller and
  # policy delegations — both prove the inline run writes into the destination.
  test "writes its sub-generators into the destination" do
    run_generator [ "admin/widgets", "size:integer" ]

    assert_file "app/controllers/admin/widgets_controller.rb"

    # The policy renders real permitted attributes from the forwarded fields
    # even though the Widget model isn't a loaded constant mid-run — proving the
    # resource path no longer falls back to the broken introspection/placeholder.
    assert_file "app/policies/admin/widget_policy.rb" do |policy|
      assert_match(/\[:size\]/, policy)
      refute_match(/create_model_first/, policy)
    end

    # The controller's route landed in the destination's routes file...
    assert_file "config/routes.rb" do |routes|
      assert_match(/cafe_car :widgets/, routes)
    end
  end

  # The whole point of blocker #4: a belongs_to must land in the emitted policy
  # as its foreign key so the association is actually savable. Asserts the real
  # generated file, not just the delegation.
  test "emits a savable foreign-key permit for a belongs_to field" do
    run_generator [ "admin/widgets", "client:references", "size:integer" ]

    assert_file "app/policies/admin/widget_policy.rb" do |policy|
      assert_match(/:client_id/, policy)
      refute_match(/[^_]:client\b/, policy)
    end
  end

  test "leaves the engine's own config/routes.rb untouched" do
    before = ENGINE_ROUTES.read

    run_generator [ "admin/widgets" ]

    assert_equal before, ENGINE_ROUTES.read,
      "resource generator must not mutate the engine's own config/routes.rb"
  end
end
