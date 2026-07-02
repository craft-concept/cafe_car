class User < ApplicationRecord
  has_many :articles, inverse_of: :author
  has_many :clients,  inverse_of: :owner
  has_many :invoices, inverse_of: :sender
  has_many :sessions, dependent: :destroy, class_name: "CafeCar::Session"

  has_secure_password
  has_one_attached :avatar
  has_many_attached :documents

  normalizes :email, with: -> { _1.strip.downcase }
  validates :name, presence: true

  default_scope -> { order(:name) }
  scope :search, -> { query("name~": _1) }

  broadcasts_refreshes

  def super? = true
end
