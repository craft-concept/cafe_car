# frozen_string_literal: true

class CafeCar::ApplicationPolicy
  include CafeCar::Policy

  attr_reader :user, :object

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

  def attributes
    @attributes ||= Attributes.new(@user, @object, permitted_attributes)
  end

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

  class Attributes < CafeCar::Attributes
  end
end
