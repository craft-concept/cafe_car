module CafeCar
  class SessionsController < const(:ApplicationController)
    include Controller

    cafe_car model: CafeCar[:Session]
    rate_limit to: 10, within: 3.minutes, only: :create # , with: -> { redirect_to new_session_path, alert: "Try again later." }
    before_action :skip_policy_scope, except: :index

    after_create :persist_session
    after_destroy :terminate_session

    private

    def find_object
      self.object = current_session
    end

    def build_object = find_object
  end
end
