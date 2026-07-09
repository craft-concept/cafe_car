class Client < ApplicationRecord
  belongs_to :owner, class_name: "User", inverse_of: :clients

  has_many :invoices

  enum :status, %i[active archived]

  validates :name, presence: true

  broadcasts_refreshes
end
