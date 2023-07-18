class V1::CustomersController < ApiController
  def index
    customer_urns = Customer.where(deleted: false)
                            .where(published: true)
                            .order(:name)
    
    customer_urns = customer_urns.search(params.dig(:filter, :search)) if params.dig(:filter, :search)

    render jsonapi: customer_urns
  end
end
