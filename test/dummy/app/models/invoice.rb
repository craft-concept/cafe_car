class Invoice < ApplicationRecord
  belongs_to :sender, class_name: "User", inverse_of: :invoices
  belongs_to :client
end
