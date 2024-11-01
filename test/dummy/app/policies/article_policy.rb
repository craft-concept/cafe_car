class ArticlePolicy < ApplicationPolicy
  def index?  = true
  def create? = true

  def show? = record.published? || record.author == user

  def permitted_attributes
    [:title, :author, :published_at, :body]
  end

  class Scope < Scope
    def resolve = scope.all
  end
end
