namespace :generate do
  desc 'Queues a job to generate the tasks for the current month'
  task tasks: :environment do
    MonthlyTasksGenerationJob.perform_later
  end
end
