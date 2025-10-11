class LineItem < ApplicationRecord
  belongs_to :invoice

  broadcasts_refreshes

  def amount = super || [*price, *quantity].reduce(&:*)
end
