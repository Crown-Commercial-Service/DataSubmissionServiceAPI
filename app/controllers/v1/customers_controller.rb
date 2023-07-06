class V1::CustomersController < ApiController
  def index
    customer_urns = Customer.where(deleted: false).where(published: true).search(params.dig(:filter,
                                                                                            :search)).order(:name)

    render jsonapi: customer_urns
  end
end
