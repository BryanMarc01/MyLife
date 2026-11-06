class User < ApplicationRecord
  has_secure_password

  has_many :ideas, dependent: :destroy
  has_many :idea_steps, dependent: :destroy
  has_many :financial_transactions, dependent: :destroy
  has_many :automation_rules, dependent: :destroy

  normalizes :email, with: ->(email) { email.to_s.strip.downcase }
  normalizes :name, with: ->(name) { name.to_s.strip }

  validates :name, presence: true
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, length: { minimum: 6 }, if: -> { new_record? || !password.nil? }

  def user_name
    name
  end
end
