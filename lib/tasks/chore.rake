namespace :chore do
  desc 'Report email address of users who belong to suppliers with outstanding tasks'
  task outstanding_task_emails: :environment do |_task|
    month = (Time.zone.today - 1.month).month
    year = Time.zone.today.year

    supplier_ids = Task
                   .where(period_month: month, period_year: year)
                   .where.not(status: 'completed')
                   .pluck(:supplier_id)
                   .uniq

    emails = User
             .active
             .joins(:memberships)
             .merge(Membership.where(supplier_id: supplier_ids))
             .pluck(:email)
             .uniq
             .sort

    file = File.new('/tmp/outstanding_task_emails.txt', 'w')
    emails.each { |email| file.puts(email) }
    file.close

    puts "Found #{supplier_ids.count} suppliers with outstanding tasks."
    puts 'Email list written to /tmp/outstanding_task_emails.txt'
  end
end
