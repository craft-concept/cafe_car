# frozen_string_literal: true

class CafeCar::BasePolicy
  include CafeCar::Policy

  attr_reader :user, :object
  alias_method :record, :object

  def initialize(user, object)
    @user   = user
    @object = object
  end

  def index?   = false
  def show?    = false
  def create?  = false
  def new?     = create?
  def update?  = false
  def edit?    = update?
  def destroy? = false

  class Scope
    def initialize(user, scope)
      @user  = user
      @scope = scope
    end

    def resolve
      raise NoMethodError, "You must define #resolve in #{self.class}"
    end

    private

    attr_reader :user, :scope
  end
end
