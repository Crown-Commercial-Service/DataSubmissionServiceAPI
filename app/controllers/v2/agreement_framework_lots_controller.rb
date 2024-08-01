class V2::AgreementFrameworkLotsController < ActionController::API
  include ApiKeyAuthenticatable

  def index
    @agreement_framework_lots = AgreementFrameworkLot.all
    render json: @agreement_framework_lots
  end
end
