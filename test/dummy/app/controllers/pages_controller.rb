class PagesController < ApplicationController
  def show
    render "/pages/#{path}"
  end

  private

  def path = params[:path].presence || "home"
end
