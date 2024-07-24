class V2::AgreementsController < ActionController::API
  include ApiKeyAuthenticatable

  def index
    @agreements = Agreement.all
    render json: @agreements
  end
end
