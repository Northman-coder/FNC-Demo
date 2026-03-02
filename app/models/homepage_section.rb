class HomepageSection < ApplicationRecord
  ALLOWED_IMAGE_TYPES = %w[image/jpeg image/png image/webp image/gif].freeze
  MAX_IMAGE_SIZE      = 5.megabytes
  SAFE_URL_REGEXP     = /\A(https?:\/\/|\/)/i.freeze

  has_one_attached :image

  validates :identifier, presence: true, uniqueness: true
  validates :link_url,
            format: { with: SAFE_URL_REGEXP, message: "must start with http://, https://, or /" },
            allow_blank: true

  validate :acceptable_image, if: -> { image.attached? }

  # Convenient finder that ensures a record exists
  def self.find_or_create(id)
    find_or_create_by(identifier: id) do |section|
      case id
      when "free_shipping"
  		section.label = "£60"
      when "guarantee_label"
        section.label = "5-Year Guarantee"
      when "footer_blurb"
        section.description = "Quality products, unbeatable prices, delivered straight to your door. Trusted by thousands of happy customers worldwide."
      when "footer_trust_line"
        section.headline = "Secure checkout • Free returns • 5-year guarantee"
      when "footer_newsletter_heading"
        section.headline = "Stay in the loop"
      when "footer_newsletter_subheading"
        section.description = "New arrivals, exclusive deals and updates — straight to your inbox."
      when "footer_privacy_label"
        section.label = "Privacy Policy"
      when "footer_terms_label"
        section.label = "Terms of Service"
      end
    end
  end

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
