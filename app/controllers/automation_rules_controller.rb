class AutomationRulesController < ApplicationController
  def index
    @active_tab = "reglas"
    @rules = AutomationRule.ordered
    @active_count = @rules.count(&:active?)
    @total_count = @rules.size
  end

  def toggle
    @rule = AutomationRule.find(params[:id])
    @rule.update!(active: !@rule.active)
    redirect_to automation_rules_path, notice: "Regla «#{@rule.title}» #{@rule.active? ? 'activada' : 'desactivada'}."
  end

  def create
    if params[:title].present? && params[:trigger_condition].present? && params[:action_result].present?
      action_text = params[:action_result].strip
      action_text = "→ #{action_text}" unless action_text.start_with?("→")
      AutomationRule.create!(
        title: params[:title].strip,
        active: true,
        trigger_condition: params[:trigger_condition].strip,
        action_result: action_text,
        confirmation_note: params[:confirmation_note].presence || "Tú confirmas antes de aplicar el cambio.",
        icon_name: params[:icon_name].presence || "list-checks",
        position: AutomationRule.maximum(:position).to_i + 1
      )
    end
    redirect_to automation_rules_path, notice: "Nueva regla creada y activada."
  end

  def destroy
    @rule = AutomationRule.find(params[:id])
    @rule.destroy!
    redirect_to automation_rules_path, notice: "Regla eliminada."
  end
end
