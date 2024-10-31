class Article < ApplicationRecord
  belongs_to :author, class_name: "User"

  validates :title, presence: true

  after_initialize :set_defaults

  private

  def set_defaults
    self.published_at ||= Time.zone.now
  end
end
