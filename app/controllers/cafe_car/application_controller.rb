class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
end

module CafeCar
  class ApplicationController < ::ApplicationController
    include Controller
  end
end
