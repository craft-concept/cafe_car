require "test_helper"
require "generators/cafe_car/policy/policy_generator"

class CafeCar::PolicyGeneratorTest < Rails::Generators::TestCase
  tests CafeCar::PolicyGenerator
  destination Rails.root.join("tmp/generators")
  setup :prepare_destination

  test "creates a namespaced policy inheriting ApplicationPolicy" do
    run_generator [ "admin/payment" ]

    assert_file "app/policies/admin/payment_policy.rb" do |policy|
      assert_match(/module Admin/, policy)
      assert_match(/class PaymentPolicy < ApplicationPolicy/, policy)
      # module_namespacing already supplies `module Admin`, so the class name
      # must not repeat it (`class Admin::PaymentPolicy` would double-namespace).
      refute_match(/class Admin::PaymentPolicy/, policy)
      assert_match(/def index\?\s+= admin\?/, policy)
      assert_match(/def destroy\?\s+= update\?/, policy)
      assert_match(/class Scope < Scope/, policy)
    end
  end

  test "lists the permitted attributes passed as arguments" do
    # --force skips the collision check so we can target a model the dummy app
    # already defines (permitted_attributes only populates for a real model).
    run_generator [ "client", "name", "email", "--force" ]

    assert_file "app/policies/client_policy.rb" do |policy|
      assert_match(/class ClientPolicy < ApplicationPolicy/, policy)
      assert_match(/\[:name, :email\]/, policy)
    end
  end
end
