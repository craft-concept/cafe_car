class PostPolicy < ApplicationPolicy
  def index?  = true
  def create? = true

  def permitted_attributes
    [:title, :body]
  end

  class Scope < Scope
    def resolve
      Post.all
    end
  end
end
