class ArticlesController < ApplicationController
  recline_in_the_cafe_car

  def scope = super.published
end
