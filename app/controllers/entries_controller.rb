class EntriesController < ApplicationController
  def create
    entry_type = params[:entry_type].presence || "ideas"
    raw_title = params[:title].to_s.strip
    return redirect_back(fallback_location: root_path) if raw_title.blank?

    case entry_type
    when "tasks"
      current_user.idea_steps.create!(
        description: raw_title,
        completed: false,
        position: current_user.idea_steps.maximum(:position).to_i + 1
      )
      redirect_to tasks_path
    when "money"
      raw_amount = params[:amount].to_s.tr(",", ".").strip
      numeric = raw_amount.to_f
      is_positive_explicit = raw_amount.start_with?("+")
      cents = (numeric.abs * 100).round
      kind = is_positive_explicit ? "income" : "expense"

      current_user.financial_transactions.update_all("position = position + 1")
      current_user.financial_transactions.create!(
        concept: raw_title,
        category: kind == "income" ? "Ingresos" : "Comida",
        kind: kind,
        amount_cents: cents,
        date_label: "Hoy",
        icon_name: "shopping-basket",
        visible_in_recent: true,
        position: 1
      )
      redirect_to finances_path
    else
      proposal = IdeaOrganizerService.propose(raw_title)
      current_user.ideas.update_all("position = position + 1")
      current_user.ideas.create!(
        title: raw_title,
        summary: proposal.summary,
        essential_summary: proposal.essential_summary,
        transcript: "«#{raw_title}»",
        category: proposal.category,
        status_tag: "Por explorar",
        source_kind: "Nota rápida",
        captured_label: "Hoy",
        captured_meta: "#{Time.current.strftime('%-d nov, %H:%M')} · Guardada",
        duration_seconds: 0,
        icon_name: proposal.icon_name,
        featured_today: false,
        visible_in_recent: true,
        next_step_preview: proposal.steps.first,
        steps_confirmed: false,
        position: 1
      )
      redirect_to ideas_path
    end
  end
end
