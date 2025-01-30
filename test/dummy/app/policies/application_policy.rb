class ApplicationPolicy < CafeCar::BasePolicy
  def admin? = true
end
