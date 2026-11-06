class UserSetting < ApplicationRecord
  validates :user_name, presence: true
  validates :monthly_budget_cents, numericality: { greater_than: 0 }

  def self.current
    setting = first_or_create!(user_name: "Alex", monthly_budget_cents: 120_000, discrete_finance_mode: false)
    setting.update_column(:user_name, "Alex") if setting.user_name == "Lucía"
    setting
  end
end
