class SessionsController < ApplicationController
  skip_before_action :require_authentication, only: [:new, :create, :social]
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

  def social
    provider = params[:provider].to_s.strip.presence || "google"
    email = params[:email].to_s.strip.downcase
    name = params[:name].to_s.strip

    if email.blank? || !email.match?(URI::MailTo::EMAIL_REGEXP)
      redirect_to login_path, alert: "Ingresa un correo válido para continuar con #{provider.capitalize}."
      return
    end

    user = User.from_social_provider(provider: provider, email: email, name: name)
    sign_in_user(user, remember: true)
    redirect_to root_path
  end

  def destroy
    sign_out_user
    redirect_to login_path, notice: "Has cerrado sesión de forma segura."
  end
end
