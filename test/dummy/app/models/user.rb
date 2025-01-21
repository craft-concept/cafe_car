class User < ApplicationRecord
  has_many :articles, inverse_of: :author
  has_secure_password

  validates :name, presence: true

  scope :search, -> { query("name~": _1) }

  def super? = true
end
