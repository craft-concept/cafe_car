class User < ApplicationRecord
  has_many :articles, inverse_of: :author

  validates :username, presence: true

  def to_s = username
end
