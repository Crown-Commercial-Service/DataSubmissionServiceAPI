class Admin::UnfinishedTasksController < AdminController
  def index
    @tasks = Task.incomplete.latest_submission_with_state(unfinished_submissions_relation(params[:status]))
                 .includes(:supplier).order('suppliers.name asc').page(params[:page]).per(12)

    respond_to do |format|
      format.html
      format.js
    end
  end

  private

  def unfinished_submissions_relation(aasm_states)
    if aasm_states.nil?
      %i[validation_failed ingest_failed in_review]
    else
      aasm_states
    end
  end
end
