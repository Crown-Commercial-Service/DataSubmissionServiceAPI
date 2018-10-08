namespace :report do
  desc 'Reports monthly task statistics. Defaults to the current month’s tasks. Override with [MM,YYYY]'
  task :submission_stats, %i[month year] => :environment do |_task, args|
    month = args[:month] || (Time.zone.today - 1.month).month
    year = args[:year] || Time.zone.today.year

    reporting_period = Date.new(year.to_i, month.to_i)

    task_period_scope = Task.where(period_year: reporting_period.year, period_month: reporting_period.month)

    puts "\nStats for #{reporting_period.strftime('%B %Y')} tasks"
    puts "Unstarted:\t#{task_period_scope.unstarted.count}"
    puts "Completed:\t#{task_period_scope.completed.count} (#{business_no_business_state(task_period_scope)})"
    puts "In Progress:\t#{task_period_scope.in_progress.count} (#{latest_submission_state(task_period_scope)})"
  end

  private

  def latest_submission_state(task_scope)
    submission_states = task_scope.in_progress.includes(:latest_submission).map { |t| t.latest_submission.aasm_state }
    stats = submission_states.each_with_object(Hash.new(0)) { |state, counts| counts[state] += 1 }

    stats.map { |state, count| "#{state} #{count}" }.join(' / ')
  end

  def business_no_business_state(task_scope)
    file_counts = task_scope.completed.includes(:latest_submission).map { |task| task.latest_submission.files.count }
    no_business_count = file_counts.count(0)
    business_count = file_counts.count(&:positive?)

    "#{business_count} Business / #{no_business_count} No Business"
  end
end
