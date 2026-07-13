module CafeCar
  class SessionsController < const(:ApplicationController)
    include Controller

    cafe_car model: CafeCar[:Session]
    rate_limit to: 10, within: 3.minutes, only: :create # , with: -> { redirect_to new_session_path, alert: "Try again later." }
    before_action :skip_policy_scope, except: :index

    after_create :persist_session
    after_destroy :terminate_session

    def create
      run_callbacks(:create) { object.save! }
      @previous_session&.destroy!
      destination = after_authentication_url
      reset_session
      respond_with object, location: destination
    end

    def destroy
      run_callbacks(:destroy) { object.destroy! }
      respond_with object, location: main_app.root_path
    end

    private

    def find_object
      self.object = current_session
    end

    def build_object
      return find_object unless action_name == "create"

      @previous_session = find_session_by_cookie(touch: false)
      CafeCar[:Current].session = self.object = build_session
    end
  end
end
