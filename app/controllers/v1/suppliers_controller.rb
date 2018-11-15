class V1::SuppliersController < APIController
  def index
    render jsonapi: Supplier.all
  end
end
