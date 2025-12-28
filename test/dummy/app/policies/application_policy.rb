class ApplicationPolicy < CafeCar::ApplicationPolicy
  def admin? = true

  class Scope < Scope
    def admin? = true
  end
end
