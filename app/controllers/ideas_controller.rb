class IdeasController < ApplicationController
  def index
    @active_tab = "ideas"
    @selected_category = params[:category].presence || "Todas"
    @search_query = params[:q].to_s.strip
    @sort = params[:sort].presence || "recent"

    @total_count = Idea.count
    @proyectos_count = Idea.where(category: "Proyectos").count
    @personal_count = Idea.where(category: "Personal").count
    @vida_diaria_count = Idea.where(category: "Vida diaria").count

    scope = Idea.by_category(@selected_category).search_query(@search_query)

    @ideas = if @sort == "alpha"
      scope.order(title: :asc)
    else
      scope.ordered
    end
  end

  def show
    @active_tab = "ideas"
    @idea = Idea.includes(:idea_steps).find_by(id: params[:id]) || Idea.includes(:idea_steps).ordered.first
  end

  def update
    @idea = Idea.find(params[:id])
    @idea.update!(idea_params)
    redirect_to idea_path(@idea), notice: "Idea actualizada."
  end

  def destroy
    @idea = Idea.find(params[:id])
    title = @idea.title
    @idea.destroy!
    redirect_to ideas_path, notice: "Idea «#{title}» eliminada."
  end

  def confirm_steps
    @idea = Idea.includes(:idea_steps).find(params[:id])
    @idea.update!(steps_confirmed: !@idea.steps_confirmed)
    if @idea.steps_confirmed?
      @idea.idea_steps.update_all(completed: true)
    end
    redirect_to idea_path(@idea), notice: @idea.steps_confirmed? ? "Pasos confirmados en tu lista de acción." : "Confirmación de pasos revertida."
  end

  def feature
    @idea = Idea.find(params[:id])
    Idea.update_all(featured_today: false)
    @idea.update!(featured_today: true)
    redirect_to idea_path(@idea), notice: "«#{@idea.title}» destacada en Inicio para retomar hoy."
  end

  private

  def idea_params
    params.require(:idea).permit(:title, :category, :status_tag, :essential_summary, :transcript)
  end
end
