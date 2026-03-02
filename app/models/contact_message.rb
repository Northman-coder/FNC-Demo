class ContactMessage < ApplicationRecord
  validates :name,    presence: true
  validates :email,   presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :message, presence: true

  scope :unread, -> { where(read: false) }
  scope :recent, -> { order(created_at: :desc) }

  def mark_read!
    update!(read: true) unless read?
  end
end
