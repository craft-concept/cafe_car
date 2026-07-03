require "test_helper"

# The active bundled theme (`CafeCar.theme`) is injected as a <link> into every
# CafeCar page's <head>. These prove the config selection reaches the rendered
# HTML, that a non-selected theme is absent, and that a bad value fails loudly
# rather than rendering unstyled.
class ThemeTest < ActionDispatch::IntegrationTest
  setup    { sign_in }
  teardown { CafeCar.theme = :warm }

  test "the selected theme is linked and non-selected themes are not" do
    CafeCar.theme = :cool

    get "/admin/clients"

    assert_response :success
    assert_select "link[href*=?]", "cafe_car/themes/cool"        # selected
    assert_select "link[href*=?]", "cafe_car/themes/cool2", false # variant not chosen
    assert_select "link[href*=?]", "cafe_car/themes/warm",  false # default not chosen
  end

  test "the default theme (:warm) is linked when the host sets nothing" do
    get "/admin/clients"

    assert_response :success
    assert_select "link[href*=?]", "cafe_car/themes/warm"
    assert_select "link[href*=?]", "cafe_car/themes/cool", false
  end

  test "an unknown theme raises rather than rendering unstyled" do
    assert_raises(ArgumentError) { CafeCar.theme = :chartreuse }
  end
end
