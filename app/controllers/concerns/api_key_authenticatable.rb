module ApiKeyAuthenticatable
  extend ActiveSupport::Concern

  included do
    before_action :authenticate_with_api_key
  end

  private

  def authenticate_with_api_key
    api_key = request.headers['API-Key']

    render json: { error: 'API key is missing' }, status: :unauthorized and return if api_key.nil?

    return if ApiKey.exists?(key: api_key)

    render json: { error: 'API key is invalid' }, status: :unauthorized and return
  end
end
