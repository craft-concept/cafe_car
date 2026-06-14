module CafeCar
  module Authentication
    extend ActiveSupport::Concern

    included do
      helper_method :authenticated?, :current_user, :current_session
    end

    private

    def authenticated?
      current_user
    end

    def current_user
      current_session.user
    end

    def current_session
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
      cookies.signed.permanent[:session_id] = {value: current_session.id, httponly: true, same_site: :lax}
    end

    def find_session_by_cookie
      cookies.signed[:session_id].try { Session.find(_1) }
    end

    def request_authentication
      session[:return_to_after_authenticating] = request.url
      redirect_to new_session_path, warning: t(:auth_required, log_in: t(:log_in))
    end

    def after_authentication_url
      session.delete(:return_to_after_authenticating) || root_url
    end
  end
end
