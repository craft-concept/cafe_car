class ApplicationController < ActionController::Base
  include Pundit::Authorization

  def current_user
    @current_user ||= User.new(username: 'bob')
  end
end
