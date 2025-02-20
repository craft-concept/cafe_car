class PagesController < ApplicationController
  before_action :skip_authorization, :skip_policy_scope

  def show
    render "/pages/#{path}"
  end

  private

  def path = params[:path].presence || "home"
end
