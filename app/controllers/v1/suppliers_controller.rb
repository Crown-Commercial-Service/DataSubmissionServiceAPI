class V1::SuppliersController < ApiController
  def index
    suppliers = current_user.suppliers

    render jsonapi: suppliers
  end
end
