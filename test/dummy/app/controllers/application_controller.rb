class ApplicationController < ActionController::Base
  include CafeCar::Controller
  include ActiveStorage::SetCurrent

  before_action :set_paper_trail_whodunnit

  def current_user
    Current.user ||= User.first || User.new(name: 'Bob')
  end
end
