class PasswordResetsController < ApplicationController
  skip_before_action :require_authentication
  layout "auth"

  def new
  end

  def create
    email = params[:email].to_s.strip.downcase
    @user = User.find_by(email: email)

    if @user
      token = @user.generate_token_for(:password_reset)
      @reset_url = edit_password_reset_path(token: token)
      flash.now[:notice] = "Hemos generado tu enlace de recuperación seguro (válido por 15 minutos)."
      render :new, status: :ok
    else
      flash.now[:alert] = "No encontramos ninguna cuenta registrada con ese correo."
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @token = params[:token].to_s
    @user = User.find_by_token_for(:password_reset, @token)
    if @user.nil?
      redirect_to forgot_password_path, alert: "El enlace de recuperación ha expirado o ya fue utilizado."
    end
  end

  def update
    @token = params[:token].to_s
    @user = User.find_by_token_for(:password_reset, @token)

    if @user.nil?
      redirect_to forgot_password_path, alert: "El enlace de recuperación ha expirado o ya fue utilizado."
      return
    end

    if params[:password].to_s.length < 6
      flash.now[:alert] = "La nueva contraseña debe tener al menos 6 caracteres."
      render :edit, status: :unprocessable_entity
    elsif params[:password] != params[:password_confirmation]
      flash.now[:alert] = "La confirmación de contraseña no coincide."
      render :edit, status: :unprocessable_entity
    else
      @user.update!(password: params[:password], password_confirmation: params[:password_confirmation])
      sign_in_user(@user, remember: true)
      redirect_to root_path
    end
  end
end
