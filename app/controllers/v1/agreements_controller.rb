class V1::AgreementsController < ApplicationController
  def create
    framework = Framework.find(agreement_params[:framework_id])
    supplier = Supplier.find(agreement_params[:supplier_id])

    agreement = Agreement.new(framework: framework, supplier: supplier)

    if agreement.save
      render jsonapi: agreement, status: :created
    else
      render jsonapi_errors: agreement.errors, status: :bad_request
    end
  end

  private

  def agreement_params
    params.permit(:framework_id, :supplier_id)
  end
end
