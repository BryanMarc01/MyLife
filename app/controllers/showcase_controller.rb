class ShowcaseController < ApplicationController
  def widgets
    @active_tab = "widgets"
    @featured_idea = Idea.find_by(featured_today: true) || Idea.find_by(title: "Un rincón para leer") || Idea.first
    @finance_summary = FinanceSummaryService.new(FinancialTransaction.all)
  end

  def identity
    @active_tab = "identity"
  end

  def studio
    @active_tab = "studio"
    @featured_idea = Idea.find_by(featured_today: true) || Idea.find_by(title: "Un rincón para leer") || Idea.first
    @newsletter_idea = Idea.find_by(title: "Newsletter de paseos") || Idea.first
    @recent_ideas = Idea.recent_visible.limit(4)
    @finance_summary = FinanceSummaryService.new(FinancialTransaction.all)
    @recent_movements = FinancialTransaction.recent_movements.limit(3)
    @rules = AutomationRule.ordered
  end
end
