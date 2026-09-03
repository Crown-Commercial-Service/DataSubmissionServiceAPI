class V1::InactiveCustomersController < ApiController
  def index
    inactive_customers = InactiveCustomer
                         .order(date_made_inactive: :desc)
                         .search(params.dig(:filter, :search))

    page_number = params.dig(:page, :page) || 1
    total_customers = inactive_customers.count
    total_pages = (total_customers.to_f / 25).ceil

    inactive_customers = inactive_customers.page(page_number).per(25)

    meta = {
      pagination: {
        total: total_customers,
          per_page: inactive_customers.limit_value,
          offset_value: inactive_customers.offset_value,
          current_page: page_number,
          total_pages: total_pages
      }
    }

    render jsonapi: inactive_customers, meta: meta
  end
end
