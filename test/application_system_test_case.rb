require "test_helper"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  driven_by :selenium, using: :headless_chrome, screen_size: [ 1280, 900 ]

  private

  def sign_in_browser
    user = create(:user, password: "secret", password_confirmation: "secret")

    visit new_session_path
    fill_in "session[email]", with: user.email
    fill_in "session[password]", with: "secret"
    click_button "Create Session"

    assert_text I18n.t("responders.success.create", default: "%{resource_name} was successfully created.",
      resource_name: CafeCar::Session.model_name.human)
    user
  end
end
