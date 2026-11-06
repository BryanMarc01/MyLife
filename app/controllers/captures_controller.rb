class CapturesController < ApplicationController
  def new
    @active_tab = "captura"
    @mode = params[:mode].presence || "voice"
    @transcript = params[:transcript].presence || ""
    @proposal = IdeaOrganizerService.propose(@transcript)
    @duration_seconds = (params[:duration_seconds] || 0).to_i
    @voice_rule_active = AutomationRule.find_by(title: "De voz a idea")&.active? != false
  end

  def preview
    @transcript = params[:transcript].to_s
    @proposal = IdeaOrganizerService.propose(@transcript)
    render json: {
      title: @proposal.title,
      category: @proposal.category,
      status_tag: @proposal.status_tag,
      summary: @proposal.summary,
      essential_summary: @proposal.essential_summary,
      first_step: @proposal.first_step,
      steps: @proposal.steps
    }
  end

  def create
    raw_transcript = params[:transcript].to_s.strip
    raw_transcript = IdeaOrganizerService::DEFAULT_TRANSCRIPT if raw_transcript.blank? && params[:title].blank?
    proposal = IdeaOrganizerService.propose(raw_transcript)

    title = params[:title].presence || proposal.title
    category = params[:category].presence || proposal.category
    status_tag = params[:status_tag].presence || proposal.status_tag
    duration = (params[:duration_seconds].presence || 18).to_i
    source_kind = params[:source_kind].presence || "Nota de voz"

    Idea.update_all("position = position + 1")

    now_str = Time.current.strftime("%-d nov, %H:%M")
    meta_str = source_kind == "Nota de voz" ? "#{now_str} · Capturada por voz · #{duration} s" : "#{now_str} · Nota rápida"

    idea = Idea.create!(
      title: title,
      summary: params[:summary].presence || proposal.summary,
      essential_summary: proposal.essential_summary,
      transcript: raw_transcript.start_with?("«") ? raw_transcript : "«#{raw_transcript}»",
      category: Idea::CATEGORIES.include?(category) ? category : "Proyectos",
      status_tag: status_tag,
      source_kind: source_kind,
      captured_label: "Ahora",
      captured_meta: meta_str,
      duration_seconds: duration,
      icon_name: proposal.icon_name,
      featured_today: params[:featured_today] == "1",
      visible_in_recent: true,
      next_step_preview: "#{proposal.steps.first} · #{category}",
      steps_confirmed: false,
      audio_data: params[:audio_data].presence,
      position: 1
    )

    steps_to_create = if AutomationRule.find_by(title: "Un paso, no una lista infinita")&.active?
      proposal.steps
    else
      [proposal.steps.first]
    end

    steps_to_create.each_with_index do |step_desc, idx|
      idea.idea_steps.create!(description: step_desc, completed: false, position: idx + 1)
    end

    redirect_to idea_path(idea), notice: "Idea «#{idea.title}» guardada y organizada."
  end
end
