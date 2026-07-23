# A customer-facing controller on the DEFAULT wiring the installer sets up:
# CafeCar::Controller via ApplicationController, no `cafe_car` macro, no
# `helper CafeCar::Helpers`. Its view sees only the safe surface
# (CafeCar::Formatting) — see helper_exposure_test.rb.
class PlainController < ApplicationController
  layout false

  def show
  end
end
