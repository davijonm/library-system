class ApplicationController < ActionController::API
  include ActionController::HttpAuthentication::Token::ControllerMethods

  before_action :authenticate_user

  private

  def authenticate_user
    token = extract_token_from_header
    if token
      decoded = JwtService.decode(token)
      if decoded && decoded['user_id']
        @current_user = User.find(decoded['user_id'])
      else
        render json: { error: 'Invalid token' }, status: :unauthorized
      end
    else
      render json: { error: 'Missing token' }, status: :unauthorized
    end
  rescue ActiveRecord::RecordNotFound, JWT::DecodeError, TypeError
    render json: { error: 'Invalid token' }, status: :unauthorized
  end

  def current_user
    @current_user
  end

  def extract_token_from_header
    authorization_header = request.headers['Authorization']
    return nil unless authorization_header

    token = authorization_header.split(' ').last
    token if token.present?
  end
end
