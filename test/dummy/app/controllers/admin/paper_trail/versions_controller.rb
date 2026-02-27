module Admin
  module PaperTrail
    class VersionsController < ApplicationController
      recline_in_the_cafe_car
      model ::PaperTrail::Version
    end
  end
end
