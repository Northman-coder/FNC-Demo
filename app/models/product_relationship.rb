class ProductRelationship < ApplicationRecord
  KINDS = %w[related complementary accessory similar bundle].freeze

  belongs_to :product
  belongs_to :related_product, class_name: "Product"

  validates :kind, presence: true, inclusion: { in: KINDS }
  validates :product_id, uniqueness: { scope: [:related_product_id, :kind], message: "relationship already exists for this kind" }
  validate :distinct_products

  scope :ordered, -> { order(position: :asc) }

  private

  def distinct_products
    return unless product_id.present? && related_product_id.present? && product_id == related_product_id

    errors.add(:related_product_id, "cannot match product")
  end
end
