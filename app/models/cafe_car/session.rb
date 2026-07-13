module CafeCar
  class Session < ApplicationRecord
    ABSOLUTE_LIFETIME = 30.days
    IDLE_LIFETIME     = 2.hours

    belongs_to :user, class_name: CafeCar.user_class_name

    attribute :email, :string
    attribute :password, :password
    attribute :login, :boolean, default: true

    validates :email, :password, presence: true, if: :login?

    before_validation :authenticate, if: :login?

    def expired?(at = Time.current)
      return false unless persisted?

      created_at <= ABSOLUTE_LIFETIME.ago(at) || updated_at <= IDLE_LIFETIME.ago(at)
    end

    def authenticate
      self.user = CafeCar.user_class.authenticate_by(email:, password:) or
        errors.add(:base, "Could not find user with given credentials")
    end
  end
end
