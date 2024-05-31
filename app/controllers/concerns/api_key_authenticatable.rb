module ApiKeyAuthenticatable
  extend ActiveSupport::Concern

  included do
    before_action :authenticate_with_api_key
  end

  private

  def authenticate_with_api_key
    api_key = request.headers['API-Key']
    Rails.logger.debug("API-Key header: #{api_key.inspect}")

    if api_key.nil?
      Rails.logger.warn('API-Key header is missing')
      render json: { error: 'API key is missing' }, status: :unauthorized and return
    end

    unless ApiKey.exists?(key: api_key)
      Rails.logger.warn("API-Key not found: #{api_key}")
      render json: { error: 'API key is invalid' }, status: :unauthorized and return
    end
  end
end