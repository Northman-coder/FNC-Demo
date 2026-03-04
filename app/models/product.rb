class Product < ApplicationRecord
  ALLOWED_IMAGE_TYPES = %w[image/jpeg image/png image/webp image/gif].freeze
  MAX_IMAGE_SIZE      = 5.megabytes

  scope :new_arrivals, -> { where(new_arrival: true).order(created_at: :desc) }
  scope :in_stock, -> { where("stock_level > 0") }
  scope :trending, -> { order(trend_score: :desc) }

  def toggle_new_arrival!
    update!(new_arrival: !new_arrival)
  end
  has_rich_text :description
  has_one_attached :image
  has_many_attached :images
  has_many :reviews
  has_many :product_relationships, dependent: :destroy
  has_many :related_products, -> { order("product_relationships.position ASC") }, through: :product_relationships, source: :related_product
  has_many :stock_alerts, dependent: :destroy
  has_many :price_alerts, dependent: :destroy
  # ... price, original_price, stock_status, sku, etc.

  validates :name, :price, presence: true
  validates :price, numericality: { greater_than_or_equal_to: 0 }
  validates :original_price, numericality: { greater_than_or_equal_to: :price }, allow_nil: true
  validates :stock_level, :low_stock_threshold, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :popularity_score, :trend_score, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  validate :acceptable_image,  if: -> { image.attached? }
  validate :acceptable_images, if: -> { images.attached? }

  # A product is considered discounted when an original price is present and
  # strictly greater than the current price.
  def discounted?
    original_price.present? && price < original_price
  end

  def low_stock?
    stock_level.to_i.positive? && stock_level <= low_stock_threshold.to_i
  end

  def sold_out?
    stock_level.to_i <= 0
  end

  def related_or_fallback(limit: 8)
    explicit = related_products.limit(limit).to_a

    if explicit.size < limit
      fallback = Product.where(category: category).where.not(id: id)
      fallback = fallback.where.not(id: explicit.map(&:id))
      explicit.concat(fallback.limit(limit - explicit.size))
    end

    return explicit if explicit.present?

    Product.where.not(id: id).limit(limit)
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