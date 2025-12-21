class ApplicationController < ActionController::Base
end

module CafeCar
  class ApplicationController < ::ApplicationController
    include Controller
  end
end
