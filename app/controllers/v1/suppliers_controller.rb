class V1::SuppliersController < ApplicationController
  def index
    @suppliers = Supplier.all
  end
end
