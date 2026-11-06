class IdeaStep < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :idea, optional: true

  validates :description, presence: true

  scope :ordered, -> { order(completed: :asc, created_at: :desc) }
end
