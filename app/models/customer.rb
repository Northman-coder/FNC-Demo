class Customer < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :orders, dependent: :destroy
  has_many :return_items, through: :orders

  validates :first_name, :last_name, presence: true

  def full_name
    "#{first_name} #{last_name}"
  end
end
