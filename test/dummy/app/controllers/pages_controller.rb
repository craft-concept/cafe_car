class PagesController < ApplicationController
  # The demo leans on the engine's layout and chrome (body_classes, Layout,
  # navigation), so it opts in to the full admin helper set. A host page on the
  # default wiring gets only the safe surface — see PlainController.
  helper CafeCar::Helpers

  def show
    render "/pages/#{path}"
  end

  private

  def path = params[:path].presence || "home"
end
