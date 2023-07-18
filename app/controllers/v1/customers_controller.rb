class V1::CustomersController < ApiController
  def index
    customer_urns = Customer.where(deleted: false)
                            .where(published: true)
                            .order(:name)
                            .search(params.dig(:filter, :search))

    render jsonapi: customer_urns
  end
end
