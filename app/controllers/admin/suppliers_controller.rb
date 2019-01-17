class Admin::SuppliersController < AdminController
  def index
    @suppliers = Supplier.page(params[:page])
  end
end
