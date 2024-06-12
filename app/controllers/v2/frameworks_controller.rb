class V2::FrameworksController < ActionController::API
  include ApiKeyAuthenticatable

  def index
    @frameworks = Framework.all
    render json: @frameworks
  end
end
