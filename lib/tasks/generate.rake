namespace :generate do
  desc 'Generates CSV of late submission contacts for a given window'
  task :late_tasks, %i[period_month year] => [:environment] do |_task, args|
    year         = args[:year]&.to_i         || Time.zone.today.year
    period_month = args[:period_month]&.to_i || (Time.zone.today - 1.month).month

    Task::OverdueUserNotificationList.new(year: year, month: period_month).generate
  end
end
