require "test_helper"

class ConsoleForgeryProtectionTest < ActiveSupport::TestCase
  # The console `app.post` convenience disables the host app's CSRF protection.
  # That mutation must be opt-in: mounting CafeCar never silently toggles a
  # consumer's own ApplicationController forgery protection.
  setup do
    @was_protection = ApplicationController.allow_forgery_protection
    @was_opt_in     = CafeCar.console_disable_forgery_protection
    ApplicationController.allow_forgery_protection = true
  end

  teardown do
    ApplicationController.allow_forgery_protection = @was_protection
    CafeCar.console_disable_forgery_protection    = @was_opt_in
  end

  test "the default leaves the host's forgery protection untouched" do
    CafeCar.disable_console_forgery_protection
    assert ApplicationController.allow_forgery_protection,
      "a view-layer gem must not disable the host's CSRF protection by default"
  end

  test "opting in disables forgery protection so console app.post works" do
    CafeCar.console_disable_forgery_protection = true
    CafeCar.disable_console_forgery_protection
    assert_not ApplicationController.allow_forgery_protection
  end
end
