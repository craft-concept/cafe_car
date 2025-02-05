class Client < ApplicationRecord
  belongs_to :owner, class_name: "User", inverse_of: :clients

  validates :name, presence: true
end
