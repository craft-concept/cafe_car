# The live demo (Railway) sets CAFE_CAR_DEMO=1 so that anonymous visitors are
# auto-signed-in as the seeded demo user on first request — see
# ApplicationController#enter_demo. Off everywhere else (tests, local dev), so
# signed-out behaviour is exercised normally.
Rails.application.config.x.cafe_car_demo = ENV["CAFE_CAR_DEMO"].present?
