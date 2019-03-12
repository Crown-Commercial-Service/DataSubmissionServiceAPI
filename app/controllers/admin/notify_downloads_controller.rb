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
    "late_notifications-#{Time.zone.today}.csv"
  end

  def task_notification_list(file)
    Task::OverdueUserNotificationList.new(month: latest_period.month, year: latest_period.year, output: file)
  end

  def latest_period
    Time.zone.today.beginning_of_month - 1.month
  end
end
