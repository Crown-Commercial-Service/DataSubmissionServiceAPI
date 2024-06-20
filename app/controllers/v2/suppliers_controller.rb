class V2::SuppliersController < ActionController::API
  include ApiKeyAuthenticatable

  def index
    @suppliers = Supplier.all
    render json: @suppliers
  end
end
