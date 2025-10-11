class Invoice < ApplicationRecord
  belongs_to :sender, class_name: "User", inverse_of: :invoices
  belongs_to :client
  has_many :line_items, dependent: :destroy

  accepts_nested_attributes_for :line_items, allow_destroy: true

  after_initialize :set_number, unless: :number?, if: :client_id?
  before_save :set_number, unless: :number?
  before_save :set_total

  validates :number, uniqueness: {scope: :client_id}

  broadcasts_refreshes

  private

  def set_number
    self.number = Invoice.where(client_id:).maximum(:number)&.succ || 1
  end

  def set_total
    self.total = line_items.sum(&:amount)
  end
end
