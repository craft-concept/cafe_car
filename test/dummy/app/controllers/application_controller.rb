class ApplicationController < ActionController::Base
  include CafeCar::Controller
  include ActiveStorage::SetCurrent

  def current_user
    Current.user ||= User.first || User.new(name: 'Bob')
  end
end
