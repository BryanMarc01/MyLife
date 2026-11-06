class ApplicationController < ActionController::Base
  allow_browser versions: :modern
  stale_when_importmap_changes

  helper_method :current_user, :logged_in?

  before_action :require_authentication
  before_action :load_bitacora_shell_stats, if: :logged_in?

  private

  def current_user
    return @current_user if defined?(@current_user)

    if session[:user_id]
      @current_user = User.find_by(id: session[:user_id])
    elsif cookies.signed[:remember_user_id] && cookies.signed[:remember_token]
      user = User.find_by(id: cookies.signed[:remember_user_id])
      if user&.authenticated_remember?(cookies.signed[:remember_token])
        session[:user_id] = user.id
        @current_user = user
      end
    end

    @current_user
  end

  def logged_in?
    current_user.present?
  end

  def sign_in_user(user, remember: false)
    reset_session
    session[:user_id] = user.id
    user.update_column(:last_login_at, Time.current)

    if remember
      raw_token = user.remember!
      cookies.signed.permanent[:remember_user_id] = { value: user.id, httponly: true, same_site: :lax }
      cookies.signed.permanent[:remember_token] = { value: raw_token, httponly: true, same_site: :lax }
    else
      user.forget!
      cookies.delete(:remember_user_id)
      cookies.delete(:remember_token)
    end
  end

  def sign_out_user
    current_user&.forget!
    cookies.delete(:remember_user_id)
    cookies.delete(:remember_token)
    reset_session
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
