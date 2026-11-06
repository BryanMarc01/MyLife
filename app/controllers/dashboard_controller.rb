class DashboardController < ApplicationController
  def show
    @active_tab = "inicio"
    @first_idea = current_user.ideas.ordered.first
    @recent_ideas = current_user.ideas.ordered.limit(4)
  end
end
