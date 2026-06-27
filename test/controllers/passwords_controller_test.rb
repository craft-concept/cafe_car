require "test_helper"

# PasswordsController is plain Rails auth scaffolding that includes
# CafeCar::Controller (via ApplicationController). It must opt out of CafeCar's
# Pundit verification and must not inherit the resource `index` action — that
# action infers a model from the controller name ("Password"), which doesn't
# exist. Regression guard for both 500s.
class PasswordsControllerTest < ActionDispatch::IntegrationTest
  test "new renders the reset-request form without a 500" do
    get "/passwords/new"
    assert_response :success
  end

  test "passwords index route is not exposed (would 500 on model inference)" do
    get "/passwords"
    assert_response :not_found
  end

  test "edit with an invalid token redirects instead of erroring" do
    get "/passwords/not-a-real-token/edit"
    assert_redirected_to new_password_path
  end
end
