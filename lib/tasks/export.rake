# Tasks to export per-entity CSV files for CCS BI
namespace :export do
  desc 'Export task entities to CSV'
  task tasks: :environment do
    filename = "/tmp/tasks_#{Time.zone.today}.csv"
    warn("Exporting tasks to #{filename}")
    File.open(filename, 'w+') do |file|
      Export::Tasks.new(Task.all, file).run
    end
  end

  desc 'Export submission entities to CSV'
  task submissions: :environment do
    filename = "/tmp/submissions_#{Time.zone.today}.csv"
    warn("Exporting submissions to #{filename}")
    File.open(filename, 'w+') do |file|
      Export::Submissions.new(Export::Submissions::Extract.all_relevant, file).run
    end
  end
end
