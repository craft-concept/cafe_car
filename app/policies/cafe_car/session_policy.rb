module CafeCar
  class SessionPolicy < ::ApplicationPolicy
    def index?   = admin?
    def create?  = true
    def show?    = true
    def destroy? = admin? || mine?
    def update?  = false

    def title_attribute = :user

    def permitted_attributes
      [ :email, :password ]
    end

    class Scope < Scope
      def resolve = scope
    end
  end
end
