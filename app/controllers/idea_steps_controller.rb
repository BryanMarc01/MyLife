class IdeaStepsController < ApplicationController
  def create
    @idea = Idea.find(params[:idea_id])
    if params[:description].present?
      next_pos = @idea.idea_steps.maximum(:position).to_i + 1
      @idea.idea_steps.create!(description: params[:description].strip, completed: false, position: next_pos)
      @idea.update!(steps_confirmed: false)
    end
    redirect_to idea_path(@idea)
  end

  def toggle
    @step = IdeaStep.find(params[:id])
    @step.update!(completed: !@step.completed)
    @idea = @step.idea
    all_done = @idea.idea_steps.reload.any? && @idea.idea_steps.all?(&:completed?)
    @idea.update!(steps_confirmed: all_done)
    redirect_to idea_path(@idea)
  end

  def destroy
    @step = IdeaStep.find(params[:id])
    @idea = @step.idea
    @step.destroy!
    redirect_to idea_path(@idea)
  end
end
