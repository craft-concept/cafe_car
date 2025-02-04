class ApplicationPolicy < CafeCar::BasePolicy
  def admin? = true

  class Scope < Scope
    def admin? = true
  end
end
