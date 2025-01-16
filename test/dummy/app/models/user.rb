class User < ApplicationRecord
  has_many :articles, inverse_of: :author
  has_secure_password

  validates :name, presence: true

  def self.search(query)
    query("name~": query)
  end
end
