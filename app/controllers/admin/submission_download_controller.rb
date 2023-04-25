class Admin::SubmissionDownloadController < AdminController
  include ActionController::Live

  def download
    send_data attachment.download, filename: attachment.filename.to_s
  end

  private

  def task
    @task ||= Task.includes(:framework, :supplier).find(params[:task_id])
  end

  def submission
    @submission ||= Submission.find(params[:submission_id])
  end

  def attachment
    @attachment ||= begin
      attachment = submission.files.first.file
      attachment.filename = "#{task.framework.short_name} #{task.supplier.name} "\
        "(#{task.period_date.to_s(:month_year)}).#{attachment.filename.extension}"
      attachment
    end
  end
end
