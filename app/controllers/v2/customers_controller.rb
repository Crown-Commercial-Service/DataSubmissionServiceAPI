class V2::CustomersController < ActionController::API
  include ApiKeyAuthenticatable

  def index
    @customers = Customer.all
    render json: @customers
  end
end
