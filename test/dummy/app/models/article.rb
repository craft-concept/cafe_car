class Article < ApplicationRecord
  belongs_to :author, class_name: "User", inverse_of: :articles

  has_rich_text :body

  validates :title, presence: true

  scope :draft, -> { where(published_at: Time.zone.now..) }
  scope :published, -> { where(published_at: ..Time.zone.now) }
  scope :unpublished, -> { where(published_at: nil) }

  def published? = published_at && published_at < Time.zone.now
  def draft?     = published_at && published_at > Time.zone.now
end
