class ArticlePolicy < ApplicationPolicy
  def index?  = true
  def create? = true

  def show?   = object.published? || edit?
  def update? = object.author == user

  def permitted_attributes
    [:title, :author_id, :published_at, :body]
  end

  class Scope < Scope
    def resolve = scope.all
  end
end
