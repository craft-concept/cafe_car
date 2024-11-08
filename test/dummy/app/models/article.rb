class Article < ApplicationRecord
  belongs_to :author, class_name: "User", inverse_of: :articles

  has_rich_text :body

  validates :title, presence: true

  def published? = published_at && published_at < Time.zone.now
end
