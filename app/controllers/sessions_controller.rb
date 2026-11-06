class SessionsController < ApplicationController
  skip_before_action :require_authentication, only: [:new, :create]
  rate_limit to: 10, within: 3.minutes, only: :create, with: -> { redirect_to login_path, alert: "Demasiados intentos. Espera un momento e inténtalo de nuevo." }
  layout "auth"

  def new
    redirect_to root_path if logged_in?
  end

  def create
    user = User.find_by(email: params[:email].to_s.strip.downcase)
    if user&.authenticate(params[:password].to_s)
      sign_in_user(user, remember: params[:remember_me] == "1")
      redirect_to root_path
    else
      flash.now[:alert] = "El correo o la contraseña no coinciden con ninguna cuenta."
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    sign_out_user
    redirect_to login_path, notice: "Has cerrado sesión de forma segura."
  end
end
