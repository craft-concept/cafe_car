class ApplicationController < ActionController::Base
  include CafeCar::Controller
  include ActiveStorage::SetCurrent

  before_action :set_paper_trail_whodunnit
end
