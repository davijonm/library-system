class ApplicationController < ActionController::API
  include ActionController::HttpAuthentication::Token::ControllerMethods
  
  before_action :authenticate_user
  
  private
  
  def authenticate_user
    @current_user = User.find(decoded_token['user_id']) if decoded_token
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'Invalid token' }, status: :unauthorized
  end
  
  def current_user
    @current_user
  end
  
  def decoded_token
    @decoded_token ||= begin
      token = extract_token_from_header
      JwtService.decode(token) if token
    end
  end
  
  def extract_token_from_header
    authorization_header = request.headers['Authorization']
    return nil unless authorization_header
    
    token = authorization_header.split(' ').last
    token if token.present?
  end
end
