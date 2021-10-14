class Admin::UnfinishedTasksController < AdminController
  def index
    @tasks = Task.incomplete.includes(:submissions).joins(:submissions)
                 .merge(unfinished_submissions_relation).order(due_on: :desc)
    @tasks = @tasks.reject { |i| i.latest_submission.aasm_state == 'processing' }
    @tasks = Kaminari.paginate_array(@tasks).page(params[:page]).per(12)

    respond_to do |format|
      format.html
      format.js
    end
  end

  private

  def unfinished_submissions_relation
    unfinished_statuses = %i[validation_failed ingest_failed in_review]
    Submission.where(aasm_state: unfinished_statuses)
  end
end
