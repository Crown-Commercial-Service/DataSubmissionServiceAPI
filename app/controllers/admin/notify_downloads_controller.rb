class Admin::NotifyDownloadsController < AdminController
  def index; end

  def show
    send_file csv_file, type: 'text/csv', filename: csv_filename
  end

  private

  def csv_file
    Tempfile.new.tap do |file|
      task_notification_list(file).generate
      file.rewind
    end
  end

  def csv_filename
    "#{params[:id]}_notifications-#{Time.zone.today}.csv"
  end

  def task_notification_list(file)
    case params[:id]
    when 'late', 'overdue'
      Task::OverdueUserNotificationList.new(month: latest_period.month, year: latest_period.year, output: file)
    when 'due'
      Task::AnticipatedUserNotificationList.new(month: current_date.month, year: current_date.year, output: file)
    end
  end

  def latest_period
    current_date.beginning_of_month - 1.month
  end

  def current_date
    Time.zone.today
  end
end
