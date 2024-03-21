class Admin::SubmissionsController < AdminController
  def show
    @submission = Submission.find(params[:id])
  end

  def details
    @submission = Submission.find(params[:submission_id])
  end
end
