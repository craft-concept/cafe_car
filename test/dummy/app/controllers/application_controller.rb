class ApplicationController < ActionController::Base
  include CafeCar::Controller
  include ActiveStorage::SetCurrent

  before_action :enter_demo
  before_action :set_paper_trail_whodunnit

  private

  # On the public live demo, hand an anonymous visitor the seeded demo identity
  # on their very first request, so a policy-scoped index (e.g. UserPolicy::Scope
  # narrows to the current user) shows a populated admin instead of the empty set
  # a nil user resolves to. This is DEMO-ONLY (config.x.cafe_car_demo is set from
  # CAFE_CAR_DEMO on the Railway container; unset everywhere else) and lives in
  # the dummy app, never the shipped gem — it does NOT weaken authorization. The
  # policies still run and scope exactly as they would for any signed-in user; we
  # only give the visitor a user to be scoped as.
  def enter_demo
    return unless Rails.application.config.x.cafe_car_demo
    return if authenticated?

    user = User.find_by(email: User::DEMO_EMAIL) or return
    CafeCar[:Current].session = CafeCar[:Session].create!(
      user:, login: false, user_agent: request.user_agent, ip_address: request.remote_ip)
    persist_session
  end
end
