class PriceAlert < ApplicationRecord
  belongs_to :product

  before_validation :ensure_token

  validates :token, presence: true
  validates :target_price, numericality: { greater_than: 0 }, allow_nil: false
  validate :contact_present

  scope :confirmed, -> { where.not(confirmed_at: nil) }
  scope :pending, -> { where(confirmed_at: nil) }

  def confirm!
    return if confirmed_at?

    update!(confirmed_at: Time.current)
  end

  private

  def contact_present
    return if email.present? || phone.present?

    errors.add(:base, "Email or phone is required")
  end

  def ensure_token
    self.token ||= SecureRandom.hex(12)
  end
end
