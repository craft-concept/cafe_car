class User < ApplicationRecord
  has_many :articles, inverse_of: :author
  has_secure_password

  validates :username, presence: true
end
