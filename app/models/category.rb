class Category < ApplicationRecord
  ALLOWED_IMAGE_TYPES = %w[image/jpeg image/png image/webp image/gif].freeze
  MAX_IMAGE_SIZE      = 5.megabytes

  has_one_attached :image
  validates :name, presence: true, uniqueness: true

  validate :acceptable_image, if: -> { image.attached? }

  private

  def acceptable_image
    unless image.content_type.in?(ALLOWED_IMAGE_TYPES)
      errors.add(:image, "must be a JPEG, PNG, WebP, or GIF")
    end
    if image.byte_size > MAX_IMAGE_SIZE
      errors.add(:image, "must be smaller than 5MB")
    end
  end
end
