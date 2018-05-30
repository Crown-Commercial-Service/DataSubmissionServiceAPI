class V1::AgreementsController < ApplicationController
  def create
    framework = Framework.find(agreement_params[:framework_id])
    supplier = Supplier.find(agreement_params[:supplier_id])

    Agreement.create!(framework: framework, supplier: supplier)
  end

  private

  def agreement_params
    params.permit(:framework_id, :supplier_id)
  end
end
