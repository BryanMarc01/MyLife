class ApplicationController < ActionController::Base
  allow_browser versions: :modern
  stale_when_importmap_changes

  helper_method :current_user, :logged_in?

  before_action :require_authentication
  before_action :load_bitacora_shell_stats, if: :logged_in?

  private

  def current_user
    return @current_user if defined?(@current_user)
    @current_user = session[:user_id] ? User.find_by(id: session[:user_id]) : nil
  end

  def logged_in?
    current_user.present?
  end

  def require_authentication
    return if logged_in?
    redirect_to login_path, alert: "Inicia sesión o crea tu cuenta para acceder a tu bitácora privada."
  end

  def load_bitacora_shell_stats
    @settings = current_user
    @total_tasks_count = current_user.idea_steps.count
    @pending_tasks_count = current_user.idea_steps.where(completed: false).count
    @completed_tasks_count = @total_tasks_count - @pending_tasks_count
    @weekly_progress_percent = @total_tasks_count.positive? ? ((@completed_tasks_count.to_f / @total_tasks_count) * 100).round : 0
    @ideas_count = current_user.ideas.count

    txs = current_user.financial_transactions.to_a
    @net_balance_cents = txs.sum { |t| t.kind == "income" ? t.amount_cents : -t.amount_cents }
  end
end
