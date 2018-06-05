class V1::SubmissionsController < ApplicationController
  def create
    framework = Framework.find(submission_params[:framework_id])
    supplier = Supplier.find(submission_params[:supplier_id])

    @submission = Submission.new(framework: framework, supplier: supplier)

    if @submission.save
      render json: @submission, status: :created
    else
      render json: @submission.errors, status: :bad_request
    end
  end

  private

  def submission_params
    params.permit(:framework_id, :supplier_id, :source, :data)
  end
end
