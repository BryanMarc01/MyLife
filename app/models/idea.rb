class Idea < ApplicationRecord
  CATEGORIES = ["Proyectos", "Personal", "Vida diaria"].freeze
  ICONS = ["route", "book-open", "coffee", "utensils"].freeze

  has_many :idea_steps, -> { order(position: :asc, id: :asc) }, dependent: :destroy

  validates :title, presence: true
  validates :summary, presence: true
  validates :category, inclusion: { in: CATEGORIES }

  scope :ordered, -> { order(position: :asc, created_at: :desc) }
  scope :recent_visible, -> { where(visible_in_recent: true).ordered }
  scope :by_category, ->(cat) { cat.present? && cat != "Todas" ? where(category: cat) : all }
  scope :search_query, ->(q) {
    if q.present?
      pattern = "%#{sanitize_sql_like(q.strip.downcase)}%"
      where("LOWER(title) LIKE :q OR LOWER(summary) LIKE :q OR LOWER(COALESCE(transcript, '')) LIKE :q OR LOWER(category) LIKE :q", q: pattern)
    else
      all
    end
  }

  def icon_bg_class
    icon_name == "route" ? "bg-purple-soft" : "bg-surface-muted"
  end

  def formatted_duration
    mins = (duration_seconds || 18) / 60
    secs = (duration_seconds || 18) % 60
    format("%02d:%02d", mins, secs)
  end
end
