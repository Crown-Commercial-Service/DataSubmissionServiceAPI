class Admin::SubmissionsController < AdminController
  def show
    @submission = Submission.find(params[:id])
  end
end
