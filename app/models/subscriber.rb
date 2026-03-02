class Subscriber < ApplicationRecord
  validates :email, presence: true, uniqueness: { case_sensitive: false },
                    format: { with: URI::MailTo::EMAIL_REGEXP }

  before_create :generate_unsubscribe_token

  private

  def generate_unsubscribe_token
    self.unsubscribe_token = SecureRandom.urlsafe_base64(24)
  end
end
