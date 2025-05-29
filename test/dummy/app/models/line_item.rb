class LineItem < ApplicationRecord
  belongs_to :invoice

  def amount = super || [*price, *quantity].reduce(&:*)
end
