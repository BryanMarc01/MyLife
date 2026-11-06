class FinanceSummaryService
  CategoryBar = Data.define(:name, :amount_cents, :formatted_amount, :percentage, :color_hex)

  def initialize(transactions = FinancialTransaction.all, budget_cents: nil)
    @transactions = transactions.to_a
    @budget_cents = budget_cents || UserSetting.current.monthly_budget_cents
  end

  attr_reader :budget_cents

  def income_cents
    @income_cents ||= @transactions.select { |t| t.kind == "income" }.sum(&:amount_cents)
  end

  def expense_cents
    @expense_cents ||= @transactions.select { |t| t.kind == "expense" }.sum(&:amount_cents)
  end

  def balance_cents
    income_cents - expense_cents
  end

  def remaining_budget_cents
    [@budget_cents - expense_cents, 0].max
  end

  def over_budget_cents
    [expense_cents - @budget_cents, 0].max
  end

  def budget_percentage
    return 0 if @budget_cents.zero?
    ((expense_cents.to_f / @budget_cents) * 100).round.clamp(0, 100)
  end

  def within_plan?
    expense_cents <= @budget_cents
  end

  def budget_warning_triggered?
    rule_active = AutomationRule.find_by(title: "El mes, bajo control")&.active?
    rule_active && @budget_cents.positive? && (expense_cents.to_f / @budget_cents) >= 0.8
  end

  def status_label
    if !within_plan?
      "Sobre el límite"
    elsif budget_warning_triggered?
      "Al #{budget_percentage} % del límite"
    else
      "Dentro del plan"
    end
  end

  def formatted_balance
    format_euros_with_decimals(balance_cents)
  end

  def formatted_expenses_with_decimals
    format_euros_with_decimals(expense_cents)
  end

  def formatted_income_short
    format_euros_short(income_cents)
  end

  def formatted_expenses_short
    format_euros_short(expense_cents)
  end

  def formatted_budget_short
    format_euros_short(@budget_cents)
  end

  def formatted_remaining_short
    format_euros_short(remaining_budget_cents)
  end

  def category_distribution
    expenses = @transactions.select { |t| t.kind == "expense" }
    hogar_cents = expenses.select { |t| t.category == "Hogar" }.sum(&:amount_cents)
    comida_cents = expenses.select { |t| t.category == "Comida" }.sum(&:amount_cents)
    otros_cents = expenses.reject { |t| ["Hogar", "Comida"].include?(t.category) }.sum(&:amount_cents)
    max_cat = [hogar_cents, comida_cents, otros_cents, 10_000].max

    [
      CategoryBar.new(
        name: "Hogar",
        amount_cents: hogar_cents,
        formatted_amount: format_euros_short(hogar_cents),
        percentage: ((hogar_cents.to_f / max_cat) * 100).round.clamp(4, 100),
        color_hex: "#6027ed"
      ),
      CategoryBar.new(
        name: "Comida",
        amount_cents: comida_cents,
        formatted_amount: format_euros_short(comida_cents),
        percentage: ((comida_cents.to_f / max_cat) * 100).round.clamp(4, 100),
        color_hex: "#9d7bef"
      ),
      CategoryBar.new(
        name: "Otros",
        amount_cents: otros_cents,
        formatted_amount: format_euros_short(otros_cents),
        percentage: ((otros_cents.to_f / max_cat) * 100).round.clamp(4, 100),
        color_hex: "#d0bff6"
      )
    ]
  end

  private

  def format_euros_with_decimals(cents)
    negative = cents.negative?
    abs_cents = cents.abs
    euros = abs_cents / 100
    rem = abs_cents % 100
    int_part = euros.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1.').reverse
    prefix = negative ? "−" : ""
    "#{prefix}#{int_part},#{format('%02d', rem)} €"
  end

  def format_euros_short(cents)
    euros = (cents / 100.0).round
    int_part = euros.abs.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1.').reverse
    "#{cents.negative? ? '−' : ''}#{int_part} €"
  end
end
