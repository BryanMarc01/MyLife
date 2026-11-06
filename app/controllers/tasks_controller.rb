class TasksController < ApplicationController
  def index
    @active_tab = "tareas"
    @tasks = current_user.idea_steps.order(created_at: :desc, id: :desc)
  end

  def create
    if params[:title].present?
      current_user.idea_steps.create!(
        description: params[:title].strip,
        completed: false,
        position: current_user.idea_steps.maximum(:position).to_i + 1
      )
    end
    redirect_to tasks_path
  end

  def toggle
    task = current_user.idea_steps.find(params[:id])
    task.update!(completed: !task.completed)
    redirect_back fallback_location: tasks_path
  end

  def destroy
    task = current_user.idea_steps.find(params[:id])
    task.destroy!
    redirect_back fallback_location: tasks_path
  end
end
