require "test_helper"

# PagesController includes CafeCar::Controller (via ApplicationController) but
# never calls `cafe_car`, so it gets none of the auto-CRUD's Pundit
# verification. Regression guard: a plain controller renders without any
# skip_authorization/skip_policy_scope and never 500s on
# Pundit::PolicyScopingNotPerformedError. (Before scoping verification to the
# `cafe_car` macro, this required per-controller skips.)
class PagesControllerTest < ActionDispatch::IntegrationTest
  test "root renders without Pundit verification and without skips" do
    get "/"

    assert_response :success
  end
end
