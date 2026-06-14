module CafeCar
  class Current < ActiveSupport::CurrentAttributes
    delegate :user, to: :session, allow_nil: true

    attribute :request_id, :user_agent, :ip_address
    attribute :session
    # attribute :user
  end
end
