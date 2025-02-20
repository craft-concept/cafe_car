class ArticlePolicy < ApplicationPolicy
  def index?   = true
  def show?    = object.published? || edit?
  def create?  = true
  def update?  = true # object.author_id == user.id
  def destroy? = update?

  def permitted_attributes
    [:title, :author_id, :published_at, :summary, :body]
  end

  class Scope < Scope
    def resolve = scope.all
  end
end
