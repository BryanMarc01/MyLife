class ApplicationController < ActionController::Base
  allow_browser versions: :modern
  stale_when_importmap_changes

  before_action :load_bitacora_shell_stats

  private

  def load_bitacora_shell_stats
    @settings = UserSetting.current
    @total_tasks_count = IdeaStep.count
    @pending_tasks_count = IdeaStep.where(completed: false).count
    @completed_tasks_count = @total_tasks_count - @pending_tasks_count
    @weekly_progress_percent = @total_tasks_count.positive? ? ((@completed_tasks_count.to_f / @total_tasks_count) * 100).round : 0
    @ideas_count = Idea.count

    txs = FinancialTransaction.all
    @net_balance_cents = txs.sum { |t| t.kind == "income" ? t.amount_cents : -t.amount_cents }
  end
end
