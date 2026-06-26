module CafeCar
  class Session < ApplicationRecord
    belongs_to :user, class_name: CafeCar.user_class_name

    attribute :email, :string
    attribute :password, :password
    attribute :login, :boolean, default: true

    validates :email, :password, presence: true, if: :login?

    before_validation :authenticate, if: :login?

    def authenticate
      self.user = CafeCar.user_class.authenticate_by(email:, password:) or
        errors.add(:base, "Could not find user with given credentials")
    end
  end
end
