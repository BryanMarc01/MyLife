class TasksController < ApplicationController
  def index
    @active_tab = "tareas"
    @tasks = IdeaStep.order(created_at: :desc, id: :desc)
  end

  def create
    if params[:title].present?
      IdeaStep.create!(
        description: params[:title].strip,
        completed: false,
        position: IdeaStep.maximum(:position).to_i + 1
      )
    end
    redirect_to tasks_path
  end

  def toggle
    task = IdeaStep.find(params[:id])
    task.update!(completed: !task.completed)
    redirect_back fallback_location: tasks_path
  end

  def destroy
    task = IdeaStep.find(params[:id])
    task.destroy!
    redirect_back fallback_location: tasks_path
  end
end
