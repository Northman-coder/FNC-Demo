class Product < ApplicationRecord
  ALLOWED_IMAGE_TYPES = %w[image/jpeg image/png image/webp image/gif].freeze
  MAX_IMAGE_SIZE      = 5.megabytes

  scope :new_arrivals, -> { where(new_arrival: true).order(created_at: :desc) }

  def toggle_new_arrival!
    update!(new_arrival: !new_arrival)
  end
  has_rich_text :description
  has_one_attached :image
  has_many_attached :images
  has_many :reviews
  # ... price, original_price, stock_status, sku, etc.

  validates :name, :price, presence: true
  validates :price, numericality: { greater_than_or_equal_to: 0 }
  validates :original_price, numericality: { greater_than_or_equal_to: :price }, allow_nil: true

  validate :acceptable_image,  if: -> { image.attached? }
  validate :acceptable_images, if: -> { images.attached? }

  # A product is considered discounted when an original price is present and
  # strictly greater than the current price.
  def discounted?
    original_price.present? && price < original_price
  end

  # query helpers
  scope :discounted, -> { where("original_price IS NOT NULL AND original_price > price") }

  private

  def acceptable_image
    unless image.content_type.in?(ALLOWED_IMAGE_TYPES)
      errors.add(:image, "must be a JPEG, PNG, WebP, or GIF")
    end
    if image.byte_size > MAX_IMAGE_SIZE
      errors.add(:image, "must be smaller than 5MB")
    end
  end

  def acceptable_images
    images.each do |img|
      unless img.content_type.in?(ALLOWED_IMAGE_TYPES)
        errors.add(:images, "must all be JPEG, PNG, WebP, or GIF")
        break
      end
      if img.byte_size > MAX_IMAGE_SIZE
        errors.add(:images, "must all be smaller than 5MB")
        break
      end
    end
  end
end