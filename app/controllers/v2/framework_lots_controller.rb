class V2::FrameworkLotsController < ActionController::API
  include ApiKeyAuthenticatable

  def index
    @framework_lots = FrameworkLot.all
    render json: @framework_lots
  end
end
