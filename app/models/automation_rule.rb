class AutomationRule < ApplicationRecord
  belongs_to :user, optional: true

  validates :title, presence: true
  validates :trigger_condition, presence: true
  validates :action_result, presence: true
  validates :confirmation_note, presence: true

  scope :ordered, -> { order(position: :asc, id: :asc) }
  scope :active_rules, -> { where(active: true) }
end
