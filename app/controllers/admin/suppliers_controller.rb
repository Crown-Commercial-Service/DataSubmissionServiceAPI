class Admin::SuppliersController < AdminController
  def index
    @suppliers = Supplier.search(params[:search]).page(params[:page])
  end

  def show
    @supplier = Supplier.find(params[:id])
  end
end
