class Article < ApplicationRecord
  belongs_to :author, class_name: "User"

  validates :title, presence: true

  after_initialize :set_defaults

  def to_s       = title
  def published? = published_at && published_at < Time.zone.now

  private

  def set_defaults
    self.published_at ||= Time.zone.now
  end
end
