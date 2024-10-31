class ApplicationController < ActionController::Base
  include Pundit::Authorization
  include CafeCar::Controller

  def current_user
    @current_user ||= User.first || User.new(username: 'bob')
  end
end
