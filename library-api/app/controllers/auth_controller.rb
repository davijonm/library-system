class AuthController < ApplicationController
  skip_before_action :authenticate_user, only: [:register, :login]

  def register
    user = User.new(user_params)

    if user.save
      token = JwtService.encode({ user_id: user.id, email: user.email, role: user.role })
      render json: {
        user: { id: user.id, email: user.email, role: user.role },
        token: token
      }, status: :created
    else
      render json: { errors: user.errors.full_messages }, status: :unprocessable_content
    end
  end

  def login
    user = User.find_by(email: params[:email])

    if user&.authenticate(params[:password])
      token = JwtService.encode({ user_id: user.id, email: user.email, role: user.role })
      render json: {
        user: { id: user.id, email: user.email, role: user.role },
        token: token
      }
    else
      render json: { error: 'Invalid email or password' }, status: :unauthorized
    end
  end

  def logout
    render json: { message: 'Logged out successfully' }
  end

  private

  def user_params
    params.require(:user).permit(:email, :password, :role)
  end
end
