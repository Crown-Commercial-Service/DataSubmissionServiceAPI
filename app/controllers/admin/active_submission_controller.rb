class Admin::ActiveSubmissionController < AdminController
  include ActionController::Live

  def download
    response.headers['Content-Type'] = attachment.content_type
    response.headers['Content-Disposition'] = "attachment; #{attachment.filename.parameters}"

    attachment.download do |chunk|
      response.stream.write(chunk)
    end
  ensure
    response.stream.close
  end

  private

  def task
    @task ||= Task.includes(:framework, :supplier, :active_submission).find(params[:task_id])
  end

  def attachment
    @attachment ||= begin
      attachment = task.active_submission.files.first.file
      attachment.filename = "#{task.framework.short_name} #{task.supplier.name} "\
        "(#{task.period_date.to_s(:month_year)}).#{attachment.filename.extension}"
      attachment
    end
  end
end
