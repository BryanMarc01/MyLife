class DashboardController < ApplicationController
  def show
    @active_tab = "inicio"
    @first_idea = Idea.ordered.first
    @recent_ideas = Idea.ordered.limit(4)
  end
end
