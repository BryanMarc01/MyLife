require "digest"

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

  generates_token_for :password_reset, expires_in: 15.minutes do
    password_salt&.last(10)
  end

  def user_name
    name
  end

  def remember!
    raw_token = SecureRandom.urlsafe_base64(32)
    update_column(:remember_digest, Digest::SHA256.hexdigest(raw_token))
    raw_token
  end

  def authenticated_remember?(raw_token)
    return false if remember_digest.blank? || raw_token.blank?
    ActiveSupport::SecurityUtils.secure_compare(
      remember_digest,
      Digest::SHA256.hexdigest(raw_token.to_s)
    )
  end

  def forget!
    update_column(:remember_digest, nil)
  end

  def self.from_social_provider(provider:, email:, name:)
    clean_email = email.to_s.strip.downcase
    user = find_by(email: clean_email)
    return user if user

    random_pw = SecureRandom.base58(20)
    create!(
      name: name.presence || clean_email.split("@").first.capitalize,
      email: clean_email,
      password: random_pw,
      password_confirmation: random_pw,
      auth_provider: provider.to_s
    )
  end
end
