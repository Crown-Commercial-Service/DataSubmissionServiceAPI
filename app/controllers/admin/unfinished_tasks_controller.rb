class Admin::UnfinishedTasksController < AdminController

  def index
    @unfinished_tasks = Task.incomplete.includes(:submissions).joins(:submissions).merge(unfinished_submissions_relation).order(due_on: :desc)
    @unfinished_tasks = @unfinished_tasks.reject { |i| i.active_submission.aasm_state == 'processing' }
  end

  private

  def unfinished_submissions_relation
    unfinished_statuses = %i[validation_failed ingest_failed in_review]
    Submission.where(aasm_state: unfinished_statuses)
  end
end