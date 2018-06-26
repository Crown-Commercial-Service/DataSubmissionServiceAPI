class V1::SuppliersController < ApplicationController
  def index
    render jsonapi: Supplier.all
  end
end
