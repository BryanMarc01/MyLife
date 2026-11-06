class FinancialTransaction < ApplicationRecord
  belongs_to :user, optional: true

  KINDS = ["expense", "income"].freeze
  CATEGORIES = ["Hogar", "Comida", "Transporte", "Otros", "Ingresos"].freeze

  validates :concept, presence: true
  validates :category, presence: true
  validates :kind, inclusion: { in: KINDS }
  validates :amount_cents, numericality: { greater_than: 0 }

  scope :expenses, -> { where(kind: "expense") }
  scope :incomes, -> { where(kind: "income") }
  scope :recent_movements, -> { where(visible_in_recent: true).order(position: :asc, created_at: :desc) }
  scope :all_movements, -> { where(kind: "expense").order(position: :asc, created_at: :desc) }

  def amount_euros
    amount_cents / 100.0
  end

  def formatted_signed_amount
    euros = amount_cents / 100.0
    formatted = format("%.2f", euros).tr(".", ",")
    sign = kind == "expense" ? "−" : "+"
    "#{sign}#{formatted} €"
  end
end
