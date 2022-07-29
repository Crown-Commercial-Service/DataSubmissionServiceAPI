class Admin::DownloadsController < AdminController
  before_action :catch_unrecognised_download, only: :show

  def index; end

  def show
    send_file csv_file, type: 'text/csv', filename: csv_filename
  end

  def new
    return redirect_to admin_downloads_path, alert: 'Please provide valid dates' unless valid_dates?

    unless valid_date_order?
      return redirect_to admin_downloads_path,
                         alert: "'From' date must be before 'To' date and 'To' date cannot be in the future"
    end

    send_file csv_file, type: 'text/csv',
filename: "customer_effort_scores-#{@from_date.to_date}-#{@to_date.to_date}.csv"
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
    when 'unfinished'
      Task::UnfinishedUserNotificationList.new(output: file)
    else
      Task::CustomerEffortScoreList.new(date_from: @from_date, date_to: @to_date.end_of_day, output: file)
    end
  end

  def latest_period
    current_date.beginning_of_month - 1.month
  end

  def current_date
    Time.zone.today
  end

  def valid_dates?
    @from_date = "#{params[:dd_from]}-#{params[:mm_from]}-#{params[:yyyy_from]}".to_datetime
    @to_date = "#{params[:dd_to]}-#{params[:mm_to]}-#{params[:yyyy_to]}".to_datetime
  rescue ArgumentError
    false
  end

  def valid_date_order?
    @to_date > @from_date && @to_date <= Time.zone.now
  end

  def catch_unrecognised_download
    head(:not_found) unless %w[due late overdue unfinished].include?(params[:id])
  end
end
