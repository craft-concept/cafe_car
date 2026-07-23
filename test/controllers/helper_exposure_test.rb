require "test_helper"

# The installer injects `include CafeCar::Controller` into the host's
# ApplicationController. That include must wire only the safe helper surface
# (CafeCar::Formatting) into host views; the admin-only overrides in
# CafeCar::Helpers — link_to, capture, method_missing, the `p` alias — ship
# solely with the `cafe_car` macro or an explicit `helper CafeCar::Helpers`.
class HelperExposureTest < ActionDispatch::IntegrationTest
  test "a plain host view renders presenters and components on the safe surface" do
    get "/plain"

    assert_response :success
    assert_select "p.price", text: "$9.50"
    assert_select ".Button.Button-primary[href='/elsewhere']", text: "Components work"
    # Rails' own link_to, unoverridden: the nested link in the view rendered
    # instead of raising "Links cannot be nested".
    assert_includes response.body, %(<a href="/inner">inner</a>)
  end

  test "the bare include wires no admin overrides into a host view context" do
    get "/plain"
    view = @controller.view_context

    assert_kind_of CafeCar::Formatting, view
    assert_not_kind_of CafeCar::Helpers, view
    assert_not_equal CafeCar::Helpers, view.method(:link_to).owner
    assert_not_equal CafeCar::Helpers, view.method(:capture).owner
    assert_equal Kernel, view.method(:p).owner, "`p` must stay Kernel#p in host views"
    assert_raises(NoMethodError, "a typo'd Capitalized call must not silently render a div") do
      view.Frobnicate
    end
  end

  test "the cafe_car macro still wires the full admin helper set" do
    sign_in
    create(:client)
    get "/admin/clients"
    view = @controller.view_context

    assert_response :success
    assert_kind_of CafeCar::Helpers, view
    assert_equal CafeCar::Helpers, view.method(:link_to).owner
    assert_equal CafeCar::Helpers, view.method(:capture).owner
    assert_equal CafeCar::Helpers, view.method(:p).owner
  end
end
