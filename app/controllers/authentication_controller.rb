class AuthenticationController < ApplicationController
  include Rails.application.routes.url_helpers
  skip_before_action :authorize_request, only: [:login, :signup]

  def signup
    user = User.new(user_params)
    if user.save
      user.image.attach(params[:user][:image]) if params[:user][:image].present?
      token = encode_token(user.id)
      render json: { user: user_response(user), token: token }, status: :created
    else
      render json: { error: user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def login
    user = User.find_by(email: params[:email])
    if user && user.authenticate(params[:password])
      token = encode_token(user.id)
      render json: { user: user_response(user), token: token }, status: :ok
    else
      render json: { error: 'Invalid credentials' }, status: :unauthorized
    end
  end

  def update
    user = User.find_by(id: params[:id])
    return render json: { error: 'User not found' }, status: :not_found unless user

    unless user.id == @current_user.id
      return render json: { error: 'Unauthorized access' }, status: :unauthorized
    end

    if params[:user][:email].present? && params[:user][:email] != user.email
      return render json: { error: ["Email can't be updated"] }, status: :unprocessable_entity
    end

    if user.update(user_update_params)
      user.image.attach(params[:user][:image]) if params[:user][:image].present?
      render json: { user: user_response(user) }, status: :ok
    else
      render json: { error: user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    user = User.find_by(id: params[:id])
    return render json: { error: 'User not found' }, status: :not_found unless user

    unless user.id == @current_user.id
      return render json: { error: 'Unauthorized access' }, status: :unauthorized
    end

    user.destroy
    head :no_content
  end


  private

  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation, :image)
  end

  def user_update_params
    params.require(:user).permit(:name, :password, :password_confirmation, :image)
  end

  def encode_token(user_id)
    JWT.encode({ user_id: user_id }, Rails.application.secret_key_base, 'HS256')
  end

  def user_response(user)
    {
      id: user.id,
      name: user.name,
      email: user.email,
      image_url: user.image.attached? ? url_for(user.image) : nil
    }
  end
end
