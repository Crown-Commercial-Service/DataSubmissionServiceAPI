class V1::CustomersController < ApiController
  def index
    customers = Customer.where(deleted: false)
                        .where(published: true)
                        .order(:name)
                        .search(params.dig(:filter, :search))

    page_number = params.dig(:page, :page) || 1
    total_customers = customers.count
    total_pages = (total_customers.to_f / 25).ceil

    customers = customers.page(page_number).per(25)

    meta = {
      pagination: {
        total: total_customers,
          per_page: customers.limit_value,
          offset_value: customers.offset_value,
          current_page: page_number,
          total_pages: total_pages
      }
    }

    render jsonapi: customers, meta: meta
  end
end
