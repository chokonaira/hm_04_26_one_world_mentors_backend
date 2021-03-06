class PasswordsController < ApplicationController
  skip_before_action :authenticate_request, only: [:forgot, :reset]

  def forgot
    if params[:email].blank?
      return render json: { error: "Email not present" }, status: :bad_request
    end

    user = User.find_by(:email => params[:email])

    if user.present?
      user.generate_password_token!
      UserNotifierMailer.send_email(user).deliver

      render json: { status: "ok" }, status: :ok
    else
      render json: { error: ["Email address not found. Please check and try again."] }, status: :not_found
    end
  end

  def reset
    token = params[:token].to_s

    if params[:token].blank?
      return render json: { error: "Token not present" }
    end

    user = User.find_by(reset_password_token: token)

    if user.present? && user.password_token_valid?
      if user.reset_password!(BCrypt::Password.create(params[:password]))
        render json: { status: "ok" }, status: :ok
      else
        render json: { error: user.errors.full_messages }, status: :unprocessable_entity
      end
    else
      render json: { error: ["Link not valid or expired. Try generating a new link."] }, status: :not_found
    end
  end
end
