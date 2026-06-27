# Exercises CafeCar::Controller#render_unauthorized in isolation: every action
# is denied so tests can assert how authorization failures degrade when the
# sessions/login infrastructure is or isn't available.
class DenialsController < ApplicationController
  rescue_from Pundit::NotAuthorizedError, with: :render_unauthorized

  def index
    raise Pundit::NotAuthorizedError, "denied"
  end
end
