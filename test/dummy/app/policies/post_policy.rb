class PostPolicy < ApplicationPolicy
  def index? = true

  class Scope < Scope
    def resolve
      Post.all
    end
  end
end
