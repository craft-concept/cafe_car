module CafeCar
  module Authentication
    extend ActiveSupport::Concern

    included do
      helper_method :authenticated?, :current_user, :current_session
    end

    private

    # Sessions/login are opt-in: a host enables them by running the
    # `cafe_car:sessions` generator and exposing the session routes. When that
    # infrastructure is absent we can't redirect to a login page, so callers
    # fall back to 403 Forbidden instead of 500ing on a missing route.
    def sessions_available?
      respond_to?(:new_session_path) && CafeCar.sessions_available?
    rescue StandardError
      false
    end

    def authenticated?
      current_user
    end

    def current_user
      current_session&.user
    end

    # No session without the opt-in infrastructure. Pundit evaluates
    # `current_user` (its default `pundit_user`) on every authorized request, so
    # building a session here would 500 a CRUD-only host that never ran
    # `cafe_car:sessions`. Gate on `sessions_available?` so it degrades to a nil
    # user (→ 403) instead.
    def current_session
      return unless sessions_available?

      CafeCar[:Current].session ||= find_session_by_cookie || build_session
    end

    def build_session
      CafeCar[:Session].new user_agent: request.user_agent,
                            ip_address: request.remote_ip
    end

    def terminate_session
      CafeCar[:Current].session.destroy!
      CafeCar[:Current].session = nil
      cookies.delete(:session_id)
    end

    def persist_session
      cookies.signed.permanent[:session_id] = { value: current_session.id, httponly: true, same_site: :lax }
    end

    def find_session_by_cookie
      cookies.signed[:session_id].try { Session.find(_1) }
    end

    def request_authentication
      session[:return_to_after_authenticating] = request.url
      redirect_to new_session_path, warning: t(:auth_required, new_session: t(:new_session))
    end

    def after_authentication_url
      session.delete(:return_to_after_authenticating) || root_url
    end
  end
end
